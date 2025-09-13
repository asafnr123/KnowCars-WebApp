variable "region" {
  description = "AWS region"
  type = string
  default = "eu-central-1"
}

variable "eks_cluster_role" {
  description = "EKS Cluster role ARN"
  type        = string
  default     = "arn:aws:iam::084375579193:role/knowcars-eks-cluster-role"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
  default     = "vpc-00ebd03bc634eabe4"
}

variable "public_subnets_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = ["subnet-093c712b6f6821a0d", "subnet-051da911561221ccc"]
}

variable "private_subnets_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = ["subnet-0aa469782eb1257a3", "subnet-0ca408221dea5455a"]
}

variable "eks_cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "knowcars-eks"
}

variable "flask_instance_type" {
  description = "EC2 instance type for Flask API"
  type        = string
  default     = "t3.medium"
}
