resource "aws_security_group" "rds_sg" {
  name = "knowcars-rds-sg"
  description = "Allow MySQL traffic only from Flask nodes"
  vpc_id = var.vpc_id

  # Ingress: Only from Flask Node Group SG
  ingress {
    description = "Allow MySQL from Flask nodes"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups  = var.flask_sg
  }

  tags = {
    Name = "knowcars-rds-sg"
  }
  
}

