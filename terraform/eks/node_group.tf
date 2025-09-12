data "aws_iam_role" "node-role" {
  name = "knowcars-eks-node-role"
}



resource "aws_eks_node_group" "flask_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "flask-api-nodes"
  node_role_arn   = data.aws_iam_role.node-role.arn
  subnet_ids      = var.private_subnets_ids
  instance_types  = [var.flask_instance_type]
  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }
  
  tags = {
    Name = "flask-api-nodes"
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}
