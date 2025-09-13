
variable "private_subnets_cidr" {
  type = list(string)
  default = ["10.0.0.128/26", "10.0.0.192/26"]
}


variable "alb_sg" {
  type        = string
  description = "Security Group ID of fargate"
}

variable "vpc_id" {
  type = string
}
