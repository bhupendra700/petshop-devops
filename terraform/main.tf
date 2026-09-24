module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "simple_petshop_vpc"
  vpc_cidr             = "10.0.0.0/16"
  igw_name             = "simple_petshop_igw"
  nat_gateway_name     = "simple_petshop_nat_gateway"
  public_subnet_name   = ["petshop_public_subnet_1", "petshop_public_subnet_2"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_name  = ["petshop_private_subnet_1", "petshop_private_subnet_2"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zone    = ["us-east-1a", "us-east-1b"]
  public_rt_name       = "simple_petshop_public_rt"
  private_rt_name      = "simple_petshop_private_rt"
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./modules/ec2"

  instance_type     = "t3.small"
  subnet_ids        = module.vpc.private_subnet_ids
  key_name          = "ec2-instance"
  security_group_id = module.security_groups.private_ec2_sg_id
  ec2_name          = ["petshop_private_ec2_1", "petshop_private_ec2_2"]
  s3_bucket_arn     = module.petshop_app_s3.bucket_arn
}

module "alb" {
  source = "./modules/alb"

  alb_name           = "simple-petshop-alb"
  alb_security_group = module.security_groups.alb_sg_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  target_group_name  = "simple-petshop-target-group"
  vpc_id             = module.vpc.vpc_id
  ec2_ids            = module.ec2.private_ec2_instance_ids
}

# 1. Project/App S3 Bucket (Public)
module "petshop_app_s3" {
  source         = "./modules/s3"
  s3_bucket_name = "petshop-app-assets-bucket"
  is_public      = true
}

# 2. Ansible SSM Temporary Bucket (Fully Private)
module "ansible_ssm_s3" {
  source         = "./modules/s3"
  s3_bucket_name = "petshop-ansible-ssm-temp-bucket"
  is_public      = false
}

module "mongodb" {
  source = "./modules/mongodb"

  project_id   = var.atlas_project_id
  cluster_name = "petshop-prod"
  region       = "US_EAST_1"

  database_username = var.mongodb_database_username
  database_password = var.mongodb_database_password

  # nat_eip = module.vpc.nat_eip
}

data "aws_secretsmanager_secret" "backend" {
  name = "petshop/prod/backend"
}

data "aws_secretsmanager_secret_version" "backend" {
  secret_id = data.aws_secretsmanager_secret.backend.id
}

resource "aws_secretsmanager_secret_version" "backend" {
  secret_id = data.aws_secretsmanager_secret.backend.id

  secret_string = jsonencode(
    merge(
      jsondecode(data.aws_secretsmanager_secret_version.backend.secret_string),
      {
        MONGO_URI = module.mongodb.connection_string
      }
    )
  )
}

resource "local_file" "ansible_inventory" {
  filename = "${path.root}/../ansible/inventory.ini"

  content = <<-EOT
    [apps]
    ${module.ec2.private_ec2_instance_ids[0]}
    ${module.ec2.private_ec2_instance_ids[1]}

    [apps:vars]
    ansible_connection=amazon.aws.aws_ssm
    ansible_aws_ssm_region=us-east-1
    ansible_aws_ssm_bucket_name=petshop-ansible-ssm-temp-bucket
    EOT
}
