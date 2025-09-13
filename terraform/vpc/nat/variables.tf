variable "eip_id" {
  description = "Elastic IP ID for the NAT Gateway"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnets IDs"
  type        = list(string)
}

