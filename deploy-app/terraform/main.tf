provider "aws" {
  region = local.location
}

locals {
  instance_type = "t2.micro"
  location = "ap-southeast-1"
  evn = "dev"
  vpc_cidr = "10.123.0.0/16"
}

module "networking" {
  source = "../module/networking"
  vpc_cidr = local.vpc_cidr
  access_ip = var.access_ip
  private_sn_count = 2
  public_sn_count = 2
  db_subnet_group = true

}

module "compute" {
  source = "../module/compute"
  instance_type = local.instance_type
  ssh_key = "test"
  alb_tg_name = "test"
  key_name = "test"
  public_subnets = module.networking.public_subnets # get from output file in networking module
  private_subnets = module.networking.private_subnets
  frontend_sg = module.networking.frontend_app_sg
  backend_sg = module.networking.backend_app_sg
  bastion_sg = module.networking.bastion_sg
}

module "database" {
    source = "../module/database"
    db_name = "manage"
    db_user = "longnh"
    db_password = "123456a@@"
    db_version = "10"
    allocated_storage = 10
    skip_final_snapshot = true
    identifier = "ee-instance-demo"
    rds_sg = module.networking.rds_sg
    instance_class = "db.t2.micro"
    db_subnet_group_name = module.networking.rds_db_subnet_group[0]
}

module "loadbalancing" {
  source = "../module/loadbalancing"
  lb_sg = module.networking.lb_sg
  public_subnets = module.networking.public_subnets
  app_sg = module.networking.frontend_app_sg
  port = 80
  vpc_id = module.networking.vpc_id
  protocol = "HTTP"
}
