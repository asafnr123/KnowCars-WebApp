data "aws_security_group" "rds_sg" {
  filter {
    name = "tag:Name"
    values = ["knowcars-rds-sg"]
   }
}

# Get the VPC ID
module "vpc" {
  source = "../vpc"
  vpc_cidr = var.vpc_cidr
}

# Get the RDS security group
module "rds_sg" {
  source = "../security_groups/rds"
  vpc_id = module.vpc.vpc_id
}



resource "aws_db_subnet_group" "mysql" {
  name       = "knowcars-mysql-subnets"
  subnet_ids = module.vpc.private_subnets_ids
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier           = "knowcars-mysql"
  username             = var.mysql_username
  password             = var.mysql_password
  skip_final_snapshot  = true
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [data.aws_security_group.rds_sg.id]
}



