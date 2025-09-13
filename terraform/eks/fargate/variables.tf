variable "cluster_name" {
  type = string
  default = "knowcars-eks"
}

variable "fargate_pod_role" {
  type = string
  default = "arn:aws:iam::084375579193:role/knowcars-eks-fargate-pod-role"
}

variable "private_subnets_ids" {
  type = list(string)
}

