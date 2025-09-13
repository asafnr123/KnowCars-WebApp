variable "vpc_id" {
  type = string
}

variable "flask_sg" {
  type        = list(string)
  description = "Security Group ID of Flask"
}

