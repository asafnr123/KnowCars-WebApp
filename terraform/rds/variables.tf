variable "private_subnets_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
  default     = ["subnet-0ca408221dea5455a","subnet-0aa469782eb1257a3"]
}

variable "rds_sg_id" {
  description = "RDS security group ID"
  type = list(string)
  default = ["sg-0bd35538397151b08"]
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
  default     = "vpc-00ebd03bc634eabe4"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/24"
}

