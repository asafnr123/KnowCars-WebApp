output "private_subnets_ids" {
  description = "IDs of the private subnets"
  value = aws_subnet.private[*].id
}
