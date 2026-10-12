module "vpc" {
  source = "../modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  vpc_name = "petshop-vpc"

  availability_zone = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]

  public_subnet_name = [
    "petshop-public-subnet-1",
    "petshop-public-subnet-2"
  ]

  private_subnet_name = [
    "petshop-private-subnet-1",
    "petshop-private-subnet-2"
  ]

  igw_name         = "petshop-igw"
  nat_gateway_name = "petshop-nat"
  public_rt_name   = "petshop-public-rt"
  private_rt_name  = "petshop-private-rt"
}

module "security_groups" {
  source = "../modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id

  deployment_type = "ecs"
}

module "ecr" {
  source = "../modules/ecr"

  project_name = var.project_name
}

module "ecs" {
  source = "../modules/ecs"

  depends_on = [module.alb]
  
  project_name       = var.project_name
  vpc_id = module.vpc.vpc_id
  execution_role_arn = module.iam.ecs_task_execution_role_arn

  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_security_group_id

  nginx_image    = "${module.ecr.nginx_repository_url}:latest"
  frontend_image = "${module.ecr.frontend_repository_url}:latest"
  backend_image  = "${module.ecr.backend_repository_url}:latest"

  backend_secret_arn = module.mongodb-secret-manager.backend_secret_arn

  target_group_arn = module.alb.target_group_arn
}

module "alb" {
  source = "../modules/alb"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  deployment_type    = "ecs"
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_security_group = module.security_groups.alb_sg_id
  domain_name        = "bhupendrayadav.me"
}

module "mongodb" {
  source = "../modules/mongodb"

  project_id   = var.atlas_project_id
  cluster_name = "petshop-prod"
  region       = "US_EAST_1"

  database_username = var.mongodb_database_username
  database_password = var.mongodb_database_password

  nat_eips = module.vpc.nat_addresses
}

module "mongodb-secret-manager" {
  source = "../modules/secret-manager"

  secret_name = "petshop/prod/backend"
  mongodb_uri = module.mongodb.connection_string
}

module "iam" {
  source = "../modules/iam"

  project_name       = var.project_name
  backend_secret_arn = module.mongodb-secret-manager.backend_secret_arn
}
