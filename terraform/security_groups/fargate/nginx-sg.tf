resource "aws_security_group" "nginx_sg" {
  name = "knowcars-nginx-sg"
  description = "Allow traffic from ALB or public internet if needed"
  vpc_id = var.vpc_id

  # Example: ingress from ALB on port 80/443
  ingress {
    description = "HTTP from ALB"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # can restrict to ALB SG later
  }

  ingress {
    description = "HTTPS from ALB"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: allow traffic to Flask API
  egress {
    description = "Allow traffic to Flask API"
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = var.vpc_cidr
  }

  # Outbound: allow traffic to Dockerhub
  egress {
    description = "Allow traffic to Dockerhub"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "knowcars-nginx-sg"
  }
}

