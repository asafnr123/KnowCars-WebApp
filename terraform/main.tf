# ═══════════════════════════════════════════════════════════════════════════════
# main.tf  –  KnowCars AWS Infrastructure
# ═══════════════════════════════════════════════════════════════════════════════

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # tls provider is needed to fetch GitHub's OIDC certificate thumbprint.
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Remote state backend.
  backend "s3" {
    bucket = "knowcars-tfstate"
    key    = "knowcars/terraform.tfstate"
    region   = "eu-central-1"   # change if your region differs
    encrypt  = true
  }
}

provider "aws" {
  region = var.aws_region
}

# ───────────────────────────────────────────────────────────────────────────────
# VARIABLES
# ───────────────────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for React static files"
  type        = string
  default     = "knowcars-frontend"
}

variable "images_bucket_name" {
  description = "S3 bucket name for cars images"
  type        = string
  default     = "knowcars-cars-images"
}

variable "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "knowcars-tfstate"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "knowcars-cluster"
}

variable "github_repo" {
  description = "GitHub repo in format owner/repo-name — used to lock OIDC trust to your repo only"
  type        = string
  default     = "asafnr123/KnowCars-WebApp" 
}

# ───────────────────────────────────────────────────────────────────────────────
# DATA SOURCES
# ───────────────────────────────────────────────────────────────────────────────

data "aws_availability_zones" "available" {
  state = "available"
}

# ───────────────────────────────────────────────────────────────────────────────
# NETWORKING
# ───────────────────────────────────────────────────────────────────────────────

resource "aws_vpc" "knowcars" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "knowcars-vpc" }
}

# Public subnets — ALB and NAT Gateway live here
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.knowcars.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                            = "knowcars-public-${count.index}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }
}

# Private subnets — EKS nodes live here, no public IPs
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.knowcars.id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                            = "knowcars-private-${count.index}"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }
}

resource "aws_internet_gateway" "knowcars" {
  vpc_id = aws_vpc.knowcars.id
  tags   = { Name = "knowcars-igw" }
}

# Elastic IP for the NAT Gateway 
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.knowcars]
  tags       = { Name = "knowcars-nat-eip" }
}

# One NAT Gateway in public AZ-a, shared by both private subnets.
resource "aws_nat_gateway" "knowcars" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "knowcars-nat-gw" }
  depends_on    = [aws_internet_gateway.knowcars]
}

# Public route table: all outbound traffic → Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.knowcars.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.knowcars.id
  }
  tags = { Name = "knowcars-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table: all outbound traffic → NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.knowcars.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.knowcars.id
  }
  tags = { Name = "knowcars-private-rt" }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ───────────────────────────────────────────────────────────────────────────────
# SECURITY GROUPS
# ───────────────────────────────────────────────────────────────────────────────

# — EKS Node Security Group ———————————————————————————————————————————————————
resource "aws_security_group" "eks_nodes" {
  name        = "knowcars-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.knowcars.id

  # Rule 1: NLB → NodePort range.
  # Kubernetes assigns a NodePort (30000-32767) for the flask-service LoadBalancer.
  # The NLB forwards external traffic to this NodePort on each node.
  # NLB preserves client source IP so we cannot restrict by security group.
  ingress {
    description = "NLB traffic to NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Rule 2: MySQL traffic from EKS nodes only (Flask pod → MySQL pod).
  ingress {
    description = "MySQL access from EKS nodes only"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true
  }

  # Rule 3: EKS control plane → kubelet on each node.
  ingress {
    description     = "EKS control plane to kubelet and webhooks"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  ingress {
    description     = "Kubelet API from EKS control plane"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
  }

  # Rule 4: Allow nodes to talk to each other (required for pod networking / CNI)
  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "All outbound - for DockerHub pulls via NAT and AWS API calls"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "knowcars-eks-nodes-sg" }
}

# — EKS Cluster (Control Plane) Security Group ————————————————————————————————
resource "aws_security_group" "eks_cluster" {
  name        = "knowcars-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = aws_vpc.knowcars.id

  # Allow kubectl and GitHub Actions to call the Kubernetes API
  ingress {
    description = "HTTPS Kubernetes API access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Control plane to nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "knowcars-eks-cluster-sg" }
}

# ───────────────────────────────────────────────────────────────────────────────
# OIDC IDENTITY PROVIDER + GITHUB ACTIONS IAM ROLE
# ───────────────────────────────────────────────────────────────────────────────

# Fetch GitHub's OIDC TLS certificate thumbprint.
# The tls provider (now declared above) handles this automatically.
data "tls_certificate" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_oidc.certificates[0].sha1_fingerprint]
}

# Trust policy — who can assume this role.
# Locked to: tokens from GitHub OIDC + your specific repo + master branch only.
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only the master branch of your specific repo can use this role
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/master"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "knowcars-github-actions-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  tags               = { Name = "knowcars-github-actions-role" }
}

# Permissions policy — what the CD pipeline is allowed to do in AWS.
# Scoped to exactly what Terraform + kubectl + AWS CLI need.
resource "aws_iam_policy" "github_actions" {
  name        = "knowcars-github-actions-policy"
  description = "Permissions for KnowCars CD pipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3AppBucketsAccess"
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::${var.frontend_bucket_name}",
          "arn:aws:s3:::${var.frontend_bucket_name}/*",
          "arn:aws:s3:::${var.images_bucket_name}",
          "arn:aws:s3:::${var.images_bucket_name}/*",
        ]
      },
      {
        Sid    = "S3TfstateAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject", "s3:PutObject",
          "s3:ListBucket", "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketRequestPayment"
        ]
        Resource = [
          "arn:aws:s3:::${var.tfstate_bucket_name}",
          "arn:aws:s3:::${var.tfstate_bucket_name}/*",
        ]
      },
      {
        Sid      = "EKSAccess"
        Effect   = "Allow"
        Action   = ["eks:*"]
        Resource = "*"
      },
      {
        Sid      = "EC2Access"
        Effect   = "Allow"
        Action   = ["ec2:*", "elasticloadbalancing:*"]
        Resource = "*"
      },
      {
        # Full IAM permissions Terraform needs to create, update, list,
        # and destroy roles, policies, and the OIDC provider.
        Sid    = "IAMAccess"
        Effect = "Allow"
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:ListRoles",
          "iam:UpdateRole", "iam:TagRole", "iam:UntagRole",
          "iam:AttachRolePolicy", "iam:DetachRolePolicy",
          "iam:ListRolePolicies", "iam:ListAttachedRolePolicies",
          "iam:PassRole",
          "iam:CreatePolicy", "iam:DeletePolicy", "iam:GetPolicy",
          "iam:GetPolicyVersion", "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion", "iam:DeletePolicyVersion",
          "iam:TagPolicy",
          "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider", "iam:TagOpenIDConnectProvider",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile", "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:ListInstanceProfilesForRole"
        ]
        Resource = "*"
      },
      {
        # CloudWatch Logs — EKS control plane logs and general observability.
        Sid    = "LogsAccess"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", "logs:DeleteLogGroup",
          "logs:DescribeLogGroups", "logs:ListTagsLogGroup",
          "logs:PutRetentionPolicy", "logs:TagLogGroup",
          "logs:TagResource", "logs:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

# ───────────────────────────────────────────────────────────────────────────────
# IAM ROLES FOR EKS
# ───────────────────────────────────────────────────────────────────────────────

resource "aws_iam_role" "eks_cluster" {
  name = "knowcars-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_nodes" {
  name = "knowcars-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# Allows you to SSH into nodes via AWS SSM Session Manager without
# opening port 22 or managing SSH keys — very useful for debugging.
resource "aws_iam_role_policy_attachment" "eks_ssm" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ───────────────────────────────────────────────────────────────────────────────
# EKS CLUSTER
# ───────────────────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 3
}


resource "aws_eks_cluster" "knowcars" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids = concat(
      aws_subnet.public[*].id,
      aws_subnet.private[*].id
    )
    # Attach the cluster SG so the control plane can reach the nodes
    security_group_ids = [aws_security_group.eks_cluster.id]
  }
  


  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  lifecycle {
    ignore_changes = [access_config]
  }

  # Enable control plane logs — visibility into API server, and auth.
  # Logs appear in CloudWatch under /aws/eks/knowcars-cluster/cluster.
  enabled_cluster_log_types = ["api", "authenticator"]
  
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks 
  ]

  tags       = { Name = "knowcars-eks" }
}

# Launch template 
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "knowcars-eks-nodes-"
  # instance_type is NOT set here — it is set in the node group below.
  # Setting it in both places causes a conflict.

  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  # Required metadata options for EKS nodes — allows the kubelet to call the
  # EC2 instance metadata service to get its identity and region.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 — more secure than v1
    http_put_response_hop_limit = 2           # must be 2 so containers on the node can also reach IMDS
  }

  tags = { Name = "knowcars-eks-launch-template" }
}

# Grant your SSO admin role access to the EKS cluster for console and kubectl access.
resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.knowcars.name
  principal_arn = "arn:aws:iam::084375579193:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_AdminAccess_8516724993890ae6"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.knowcars.name
  principal_arn = "arn:aws:iam::084375579193:role/aws-reserved/sso.amazonaws.com/eu-central-1/AWSReservedSSO_AdminAccess_8516724993890ae6"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

# Grant the AWS root account access to the EKS cluster for web console visibility.
resource "aws_eks_access_entry" "root" {
  cluster_name  = aws_eks_cluster.knowcars.name
  principal_arn = "arn:aws:iam::084375579193:root"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "root_admin" {
  cluster_name  = aws_eks_cluster.knowcars.name
  principal_arn = "arn:aws:iam::084375579193:root"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.root]
}

# Grant the GitHub Actions IAM role access to the EKS cluster Kubernetes API.
resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = aws_eks_cluster.knowcars.name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = aws_eks_cluster.knowcars.name
  principal_arn = aws_iam_role.github_actions.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_actions]
}

# EKS node group — EC2 instances in PRIVATE subnets.
resource "aws_eks_node_group" "knowcars" {
  cluster_name    = aws_eks_cluster.knowcars.name
  node_group_name = "knowcars-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = ["t3.small"]

  # Wire in the launch template so the node SG is actually attached to the EC2 instances.
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr_read,
    aws_iam_role_policy_attachment.eks_ssm,
  ]

  tags = { Name = "knowcars-node-group" }
}


# ───────────────────────────────────────────────────────────────────────────────
# S3 BUCKETS
# ───────────────────────────────────────────────────────────────────────────────

# Frontend — public static website hosting
resource "aws_s3_bucket" "frontend" {
  bucket        = var.frontend_bucket_name
  force_destroy = true
  tags          = { Name = "knowcars-frontend" }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.frontend.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.frontend]
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key    = "index.html" }
}

# Car images — public (future images uploaded here, current ones served by Flask)
resource "aws_s3_bucket" "car_images" {
  bucket        = var.images_bucket_name
  force_destroy = true
  tags          = { Name = "knowcars-cars-images" }
}

resource "aws_s3_bucket_public_access_block" "car_images" {
  bucket                  = aws_s3_bucket.car_images.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "car_images" {
  bucket = aws_s3_bucket.car_images.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.car_images.arn}/*"
    }]
  })
  depends_on = [aws_s3_bucket_public_access_block.car_images]
}


# ───────────────────────────────────────────────────────────────────────────────
# EBS CSI DRIVER — required for dynamic EBS volume provisioning (MySQL PVC)
# ───────────────────────────────────────────────────────────────────────────────

# Fetch the EKS cluster's OIDC thumbprint so the CSI driver pod can assume an IAM role.
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.knowcars.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.knowcars.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

# IAM role that the EBS CSI driver pods will assume via IRSA.
resource "aws_iam_role" "ebs_csi_driver" {
  name = "knowcars-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.knowcars.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_driver,
    aws_eks_node_group.knowcars,
  ]
}

# ───────────────────────────────────────────────────────────────────────────────
# OUTPUTS
# ───────────────────────────────────────────────────────────────────────────────
output "github_actions_role_arn" {
  description = "Copy into AWS_GITHUB_ACTIONS_ROLE_ARN GitHub Secret"
  value       = aws_iam_role.github_actions.arn
}

output "eks_cluster_name" {
  description = "Copy into EKS_CLUSTER_NAME GitHub Secret"
  value       = aws_eks_cluster.knowcars.name
}

output "frontend_website_url" {
  description = "URL to access the React frontend"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

