resource "aws_vpc" "simple_petshop_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "simple_petshop_vpc"
  }
}

resource "aws_subnet" "simple_petshop_public_subnet" {
  vpc_id                  = aws_vpc.simple_petshop_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # assign public_ip

  tags = {
    Name = "simple_petshop_public_subnet"
  }
}

resource "aws_internet_gateway" "simple_petshop_igw" {
  vpc_id = aws_vpc.simple_petshop_vpc.id

  tags = {
    Name = "simple_petshop_igw"
  }
}

resource "aws_route_table" "simple_petshop_public_rt" {
  vpc_id = aws_vpc.simple_petshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simple_petshop_igw.id
  }

  tags = {
    Name = "simple_petshop_public_rt"
  }
}

resource "aws_route_table_association" "simple_petshop_public_rta" {
  subnet_id      = aws_subnet.simple_petshop_public_subnet.id
  route_table_id = aws_route_table.simple_petshop_public_rt.id
}

resource "aws_network_interface" "simple_petshop_nic" {
  subnet_id = aws_subnet.simple_petshop_public_subnet.id

  tags = {
    Name = "simple-petshop-nic"
  }
}

resource "aws_security_group" "simple_petshop_sg" {
  name        = "simple-petshop-sg"
  description = "Security group for Petshop EC2"
  vpc_id      = aws_vpc.simple_petshop_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simple-petshop-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "simple_petshop_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"

  subnet_id                   = aws_subnet.simple_petshop_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.simple_petshop_sg.id]
  associate_public_ip_address = true

  key_name = "ec2-instance"

  tags = {
    Name = "simple_petshop_ec2"
  }
}

resource "aws_s3_bucket" "petshop_s3" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = var.s3_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "petshop_s3_permission" {
  bucket = aws_s3_bucket.petshop_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.petshop_s3.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.petshop_s3.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

resource "local_file" "inventory" {
  content  = "[webservers]\n${aws_instance.simple_petshop_ec2.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/bhupendra/.ssh/ec2-instance.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
  filename = "../ansible/inventory.ini"
}

resource "null_resource" "run_ansible" {

  triggers = {
    instance_id = aws_instance.simple_petshop_ec2.id
  }

  depends_on = [
    aws_instance.simple_petshop_ec2,
    local_file.inventory
  ]

  provisioner "local-exec" {
    command     = "wsl -d Ubuntu bash -c 'cd /mnt/c/Users/bhupendra/Desktop/Devops/petshop-devops/ansible && mkdir -p ~/.ssh && cp /mnt/c/Users/bhupendra/Downloads/ec2-instance.pem ~/.ssh/ec2-instance.pem && chmod 600 ~/.ssh/ec2-instance.pem && ansible-playbook -i inventory.ini playbook.yml'"
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "local_file" "backend_env" {
  filename = "${path.module}/../backend/.env"
  content  = <<EOT
# NODE_ENV=production
NODE_ENV=development 
PORT=5000
JWT_SECRET=${var.jwt_secret}

# CLIENT_URL=http://localhost:3000

# MONGO_URI=mongodb://127.0.0.1:27017/petshop

MONGO_URI=mongodb://database:27017/petshop

PAYPAL_CLIENT_ID=${var.paypal_client}

AWS_ACCESS_KEY_ID=${var.aws_access_key}
AWS_SECRET_ACCESS_KEY=${var.aws_secret_key}
AWS_REGION=${var.aws_region}
AWS_S3_BUCKET_NAME=${var.s3_bucket_name}

ADMIN_NAME=${var.admin_name}
ADMIN_EMAIL=${var.admin_email}
ADMIN_PASSWORD=${var.admin_password}
EOT
}