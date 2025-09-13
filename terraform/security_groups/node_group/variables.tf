variable "vpc_id" {
  type = string
}

variable "nginx_sg" {
  type        = string
  description = "Security Group ID of Nginx"
}

variable "vpc_cidr" {
  type = string
}
