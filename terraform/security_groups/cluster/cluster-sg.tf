resource "aws_security_group" "eks_cluster_sg" {
  name   = "knowcars-cluster-sg"
  description = "Allow allows traffic from worker nodes and fargate"
  vpc_id = var.vpc_id
  
  # Allow ALB traffic to pods (Nginx)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg]
    description     = "Allow traffic from ALB"
  }

  # Allow pods to communicate with Flask EC2 (port 5000)
  egress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    cidr_blocks     = var.private_subnets_cidr
    description     = "Allow pods to reach Flask API"
  }

  # Allow internet access for dockerhub
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for DockerHub"
  }
  
  tags = {
    Name = "knowcars-cluster-sg"
  }
}

