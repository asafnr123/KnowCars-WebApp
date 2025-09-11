variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "mysql_username" {
  description = "root user for RDS"
  type        = string
  sensitive   = true
}


variable "mysql_password" {
  description = "rds root password"
  type        = string
  sensitive   = true
}


variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = list(string)
}

