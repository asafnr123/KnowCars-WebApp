
resource "aws_eks_fargate_profile" "nginx" {
  cluster_name           = var.cluster_name
  fargate_profile_name   = "nginx-fargate"
  pod_execution_role_arn = var.fargate_pod_role
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
  
  
}

