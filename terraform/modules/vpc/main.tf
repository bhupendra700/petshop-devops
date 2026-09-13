resource "aws_vpc" "petshop_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_default_security_group" "vpc_default_sg" {
  vpc_id = aws_vpc.petshop_vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}_sg"
  }
}

resource "aws_default_network_acl" "vpc_default_nacl" {
  default_network_acl_id = aws_vpc.petshop_vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.vpc_name}_nacl"
  }
}

resource "aws_default_route_table" "vpc_default_main_rt" {
  default_route_table_id = aws_vpc.petshop_vpc.default_route_table_id

  tags = {
    Name = "${var.vpc_name}_default_main_rt"
  }
}

resource "aws_internet_gateway" "petshop_igw" {
  vpc_id = aws_vpc.petshop_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  vpc_id            = aws_vpc.petshop_vpc.id
  availability_mode = "regional"

  tags = {
    Name = var.nat_gateway_name
  }
}

resource "aws_ec2_tag" "nat_edge_route_table_name" {
  resource_id = aws_nat_gateway.nat_gateway.route_table_id
  key         = "Name"
  value       = "${var.nat_gateway_name}_edge_rt"
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.petshop_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.public_subnet_name}_${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.petshop_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.private_subnet_name}_${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.petshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.petshop_igw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.petshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = var.private_rt_name
  }
}

resource "aws_route_table_association" "public_rta" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}