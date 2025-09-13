resource "aws_eks_cluster" "this" {
  name     = var.eks_cluster_name
  role_arn = var.eks_cluster_role
  version  = "1.27"

  vpc_config {
    subnet_ids = var.private_subnets_ids
  }

  
}

