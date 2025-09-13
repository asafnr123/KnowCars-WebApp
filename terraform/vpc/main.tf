resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames  = true

  tags = {
    Name = "knowCars-vpc"
  }
}


module "subnets" {
  source = "./subnets"
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  vpc_id = aws_vpc.main.id
  azs = var.azs
}

module "igw" {
  source = "./igw"
  vpc_id = aws_vpc.main.id
}

module "nacls" {
  source = "./nacls"
  vpc_id = aws_vpc.main.id
  vpc_cidr = var.vpc_cidr
  private_subnet_ids = module.subnets.private_subnet_ids
  public_subnet_ids = module.subnets.public_subnet_ids
}

module "eip" {
  source = "./eip"
}

module "nat" {
  source = "./nat"
  eip_id = module.eip.eip_id
  public_subnet_ids = module.subnets.public_subnet_ids
}

module "route_tables" {
  source = "./route_table"
  vpc_id = aws_vpc.main.id
  igw_id = module.igw.igw_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  nat_id = module.nat.nat_id
}
