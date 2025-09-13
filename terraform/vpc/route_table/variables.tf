variable "vpc_id" {
  description = "VPC ID for route tables"
  type        = string
}

variable "igw_id" {
  description = "Internet Gateway ID for public route table"
  type        = string
}

variable "public_subnets_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "nat_id" {
  description = "NAT Gateway ID for private route table"
  type        = string
}
