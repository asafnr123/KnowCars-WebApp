variable "nodes_role" {
  type = string
  description = "ARN of the Node_group role"
  default = "arn:aws:iam::084375579193:role/knowcars-eks-node-role"
}

variable "cluster name" {
  type = string
  default = "knowcars-eks"
}

variable "private_subnets_ids" {
  type = list(string)
  default = ["subnet-0aa469782eb1257a3","subnet-0ca408221dea5455a"]
}

variable "flask_instance_type" {
  type = list(string)
  default = "t3.medium"
}


