module "fargate" {
  source = "./fargate"
  vpc_id = var.vpc_id
  vpc_cidr = [var.vpc_cidr]
}

module "node_group" {
  source   = "./node_group"
  vpc_id   = var.vpc_id
  vpc_cidr = [var.vpc_cidr]
  nginx_sg = [module.fargate.nginx_sg_id]
}

module "rds" {
  source   = "./rds"
  vpc_id   = var.vpc_id
  flask_sg = [module.node_group.flask_sg_id]
}

module "cluster" {
  source = "./cluster"
  vpc_id   = var.vpc_id
  flask_sg = [module.node_group.flask_sg_id]
  nginx_sg = [module.fargate.nginx_sg_id]
}
  
