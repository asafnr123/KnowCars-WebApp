module "rds_sg" {
  source = "../security_groups/rds"
  vpc_id = var.vpc_id
  vpc_cidr = var.vpc_cidr
}

resource "aws_db_subnet_group" "mysql" {
  name       = "knowcars-mysql-subnets"
  subnet_ids = var.private_subnets
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
  vpc_security_group_ids = [module.rds_sg.rds_sg_id]
}



