resource "aws_security_group" "alb_sg" {
  name = "knowcars-alb-sg"
  description = "Allow traffic from internet to fargate-pods"
  vpc_id = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress: to cluster SG (Fargate pods)
  egress {
    description     = "Allow traffic to Fargate pods"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.private_subnets_cidr
  }

  tags = {
    Name = "knowcars-alb-sg"
  }
}

