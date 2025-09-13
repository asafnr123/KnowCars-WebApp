output "eks_cluster_resource" {
  value       = aws_eks_cluster.this
  description = "The EKS cluster resource object"
}

output "name" {
  value       = aws_eks_cluster.this.name
  description = "The name of the EKS cluster"
}
