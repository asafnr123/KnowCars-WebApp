output "rds_sg_id" {
  value       = aws_security_group.rds_sg.id
  description = "The ID of the RDS security group"
}
