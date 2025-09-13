variable "vpc_cidr" {
  description = "VPC cidr"
  type        = string
  default     = "10.0.0.0/24"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-00ebd03bc634eabe4"
}

variable "private_subnets_cidr" {
  type = list(string)
  default = ["10.0.0.128/26", "10.0.0.192/26"]
}
