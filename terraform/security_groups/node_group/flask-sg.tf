resource "aws_security_group" "flask_sg" {
  name = "knowcars-flask-sg"
  description = "Allow Flask API traffic only from Nginx pods"
  vpc_id = var.vpc_id

  # Ingress: Only from fargate-pods SG
  ingress {
    description = "Allow traffic from Nginx pods"
    from_port = 5000    # Flask API port
    to_port = 5000
    protocol = "tcp"
    security_groups  = [var.cluster_sg]
  }

  # Outbound: allowed for dockerhub
  egress {
    description = "Allow HTTPS for DockerHub"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

  # Outbound to RDS SG
  egress {
    description     = "Allow MySQL to RDS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = var.private_subnets_cidr
}

  tags = {
    Name = "knowcars-flask-sg"
  }
  
}
  

