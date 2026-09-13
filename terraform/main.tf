module "vpc" {
  source               = "./modules/vpc"
  vpc_name             = "simple_petshop_vpc"
  vpc_cidr             = "10.0.0.0/16"
  igw_name             = "simple_petshop_igw"
  nat_gateway_name     = "simple_petshop_nat_gateway"
  public_subnet_name   = "simple_petshop_public_subnet"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_name  = "simple_petshop_private_subnet"
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zone    = ["us-east-1a", "us-east-1b"]
  public_rt_name       = "simple_petshop_public_rt"
  private_rt_name      = "simple_petshop_private_rt"
}

module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
  security_groups = {
    "alb-sg" = {
      description = "Security Group for ALB"

      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    "simple_petshot_private_ec2_sg" = {
      description = "Security Group for Simple Petshot Private EC2"

      ingress = []
    }

    "simple_petshot_public_ec2_sg" = {
      description = "Security Group for Simple Petshot Public EC2"

      ingress = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}

module "ec2" {
  source = "./modules/ec2"

  private_instance_type = "t3.small"
  public_instance_type  = "t3.small"

  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_id   = module.vpc.public_subnet_ids[0]

  key_name = "ec2-instance"

  private_instance_security_group_id = module.security_groups.security_group_ids["simple_petshot_private_ec2_sg"]
  public_instance_security_group_id  = module.security_groups.security_group_ids["simple_petshot_public_ec2_sg"]

  private_ec2_name = "simple_petshop_private_ec2"
  public_ec2_name = "simple_petshop_public_ec2"

  s3_bucket_arn = module.s3.bucket_arn
}

module "alb" {
  source = "./modules/alb"

  alb_name = "simple-petshop-alb"

  alb_security_group = module.security_groups.security_group_ids["alb-sg"]

  public_subnet_ids = module.vpc.public_subnet_ids

  target_group_name = "simple-petshop-target-group"

  vpc_id = module.vpc.vpc_id

  ec2_ids = module.ec2.private_ec2_ids
}

module "s3" {
  source = "./modules/s3"

  s3_bucket_name = var.s3_bucket_name
}

resource "local_file" "ansible_inventory" {
  filename = "${path.root}/../ansible/inventory.ini"

  content = <<-EOT
    [apps]
    ${join("\n", module.ec2.private_ec2_private_ips)}

    [apps:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=~/.ssh/ec2-instance.pem
    ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ~/.ssh/ec2-instance.pem -o StrictHostKeyChecking=no -W %h:%p ubuntu@${module.ec2.public_ec2_public_ips}"'
  EOT
}

# resource "null_resource" "run_ansible" {

#   triggers = {
#     instance_id = aws_instance.simple_petshop_ec2.id
#   }

#   depends_on = [
#     aws_instance.simple_petshop_ec2,
#     local_file.inventory
#   ]

#   provisioner "local-exec" {
#     command     = "wsl -d Ubuntu bash -c 'cd /mnt/c/Users/bhupendra/Desktop/Devops/petshop-devops/ansible && mkdir -p ~/.ssh && cp /mnt/c/Users/bhupendra/Downloads/ec2-instance.pem ~/.ssh/ec2-instance.pem && chmod 600 ~/.ssh/ec2-instance.pem && ansible-playbook -i inventory.ini playbook.yml'"
#     interpreter = ["PowerShell", "-Command"]
#   }
# }