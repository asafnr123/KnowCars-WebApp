module "cluster" {
  source = "./cluster"
  vpc_id   = var.vpc_id
  alb_sg = module.alb.nginx_sg_id
  private_subnets_cidr = var.private_subnets_cidr
}

module "alb" {
  source = "./alb"
  vpc_id = var.vpc_id
  private_subnets_cidr = var.private_subnets_cidr
}

module "node_group" {
  source   = "./node_group"
  vpc_id   = var.vpc_id
  cluster_sg = module.cluster.cluster_sg_id
  private_subnets_cidr = var.private_subnets_cidr
}

module "rds" {
  source   = "./rds"
  vpc_id   = var.vpc_id
  flask_sg = module.node_group.flask_sg_id
}

  
