variable "vpc_id" {
  type = string
}

variable "private_subnets_cidr" {
  type = list(string)
  default = ["10.0.0.128/26", "10.0.0.192/26"]
}

