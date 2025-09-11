resource "aws_security_group" "flask_sg" {
  name = "knowcars-flask-sg"
  description = "Allow Flask API traffic only from Nginx pods"
  vpc_id = var.vpc_id

  # Ingress: Only from Nginx SG
  ingress {
    description = "Allow traffic from Nginx pods"
    from_port = 5000    # Flask API port
    to_port = 5000
    protocol = "tcp"
    security_groups  = [aws_security_group.nginx_sg.id]
  }

  # Outbound: allowed for dockerhub and mysql
  egress {
    description = "Allow traffic for dockerhub and mysql"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "knowcars-flask-sg"
  }
  
  depends_on = [aws_security_group.nginx_sg]
}

