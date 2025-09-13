output "eip_id" {
  description = "Elastic IP for NAT"
  value = aws_eip.nat.id
}
