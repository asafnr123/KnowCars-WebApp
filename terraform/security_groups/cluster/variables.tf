variable "flask_sg" {
  type        = list(string)
  description = "Security Group ID of worker nodes"
}


variable "nginx_sg" {
  type        = list(string)
  description = "Security Group ID of fargate"
}

variable "vpc_id" {
  type = string
}
