data "aws_iam_role" "eks_cluster_role" {
  name = "knowcars-eks-cluster-role"
}



resource "aws_eks_cluster" "this" {
  name     = var.eks_cluster_name
  role_arn = data.aws_iam_role.eks_cluster_role.arn
  version  = "1.27"

  vpc_config {
    subnet_ids = var.private_subnets_ids
  }
  
  tags = {
    Name = var.eks_cluster_name
  }

}

