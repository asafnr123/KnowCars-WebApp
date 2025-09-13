variable "flask_sg" {
  type        = string
  description = "Security Group ID of worker nodes"
}


variable "fargate_sg" {
  type        = string
  description = "Security Group ID of fargate"
}

