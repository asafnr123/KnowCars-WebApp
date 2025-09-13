data "aws_iam_role" "fargate-pod-role" {
  name ="knowcars-eks-fargate-pod-role"
}


resource "aws_eks_fargate_profile" "nginx" {
  cluster_name           = aws_eks_cluster.this.name
  fargate_profile_name   = "nginx-fargate"
  pod_execution_role_arn = data.aws_iam_role.fargate-pod-role.arn
  subnet_ids             = var.private_subnets_ids

  selector {
    namespace = "production"
    labels = {
      app = "nginx"
    }
  }
  
  tags = {
    Name = "nginx-fargate"
  }
  
  depends_on = [
    aws_eks_cluster.this
  ]
  
}

