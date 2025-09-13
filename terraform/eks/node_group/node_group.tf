
resource "aws_eks_node_group" "flask_nodes" {
  cluster_name    = var.cluster_name
  node_group_name = "flask-api-nodes"
  node_role_arn   = var.nodes_role
  subnet_ids      = var.private_subnets_ids
  instance_types  = var.flask_instance_type
  ami_type = "AL2_x86_64"
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }
  
  labels = {
    role = "flask-api"
  }
  
  tags = {
    Name = "flask-api-nodes"
  }
  
  depends_on = var.eks_cluster
}
