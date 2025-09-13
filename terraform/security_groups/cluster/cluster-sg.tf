resource "aws_security_group" "eks_cluster_sg" {
  name   = "eks-cluster-sg"
  vpc_id = var.vpc_id

  # Allow worker nodes to talk to the cluster API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = var.flask_sg
    description = "Allow worker nodes to communicate with EKS API"
  }

  # Allow Fargate pods to talk to the cluster API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = var.nginx_sg
    description = "Allow Fargate pods to communicate with EKS API"
  }

  # Allow all outbound (default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

