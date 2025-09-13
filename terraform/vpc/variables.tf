variable "vpc_cidr" {
  default = "10.0.0.0/24"
}

variable "region" {
  default = "eu-central-1"
}

variable "azs" {
  type = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "public_subnets_cidr" {
  type = list(string)
  default = ["10.0.0.0/26", "10.0.0.64/26"]
}

variable "private_subnets_cidr" {
  type = list(string)
  default = ["10.0.0.128/26", "10.0.0.192/26"]
}




