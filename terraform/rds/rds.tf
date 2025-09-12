# Get the RDS security group
data "aws_security_group" "rds_sg" {
  filter {
    name = "tag:Name"
    values = ["knowcars-rds-sg"]
   }
}

# Get private subnets 
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["knowCars-private-1", "knowCars-private-2"]  
  }
}


resource "aws_db_subnet_group" "mysql" {
  name       = "knowcars-mysql-subnets"
  subnet_ids = data.aws_subnets.private.ids
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



