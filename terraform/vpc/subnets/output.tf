output "public_subnet_ids" {
  description = "Public subnets IDs"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnets IDs"
  value = aws_subnet.private[*].id
}
