variable "region" {
  description = "AWS region"
  type = string
  default = "eu-central-1"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
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
