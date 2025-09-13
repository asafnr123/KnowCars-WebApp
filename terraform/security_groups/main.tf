
module "nginx" {
  source = "./nginx"
  vpc_id = var.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "flask" {
  source   = "./flask"
  vpc_id   = var.vpc_id
  vpc_cidr = var.vpc_cidr
  nginx_sg = module.nginx.nginx_sg_id
}

module "rds" {
  source   = "./rds"
  vpc_id   = var.vpc_id
  flask_sg = module.flask.flask_sg_id
}
