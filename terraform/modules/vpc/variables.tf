# ==========================================
# VPC & Gateway Configurations
# ==========================================

variable "vpc_cidr" {
  description = "The IP address range for the entire VPC (e.g., 10.0.0.0/16). This defines the total network boundary."
  type        = string
}

variable "vpc_name" {
  description = "A friendly tag name for the VPC to identify it easily in the AWS Console (e.g., my-app-vpc)."
  type        = string
}

variable "igw_name" {
  description = "The Name tag for the Internet Gateway, which allows public subnets to access the internet."
  type        = string
}

variable "nat_gateway_name" {
  description = "The Name tag for the NAT Gateway, which allows private subnets to access the internet securely without exposing them."
  type        = string
}

# ==========================================
# Subnet Configurations
# ==========================================

variable "public_subnet_name" {
  description = "Base prefix name for public subnets (e.g., public-subnet). Numbers like _1, _2 will be appended automatically."
  type        = string
}

variable "private_subnet_name" {
  description = "Base prefix name for private subnets (e.g., private-subnet). Numbers like _1, _2 will be appended automatically."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of IP ranges for public subnets (e.g., ['10.0.1.0/24', '10.0.2.0/24']). Used for internet-facing resources like Load Balancers."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of IP ranges for private subnets (e.g., ['10.0.3.0/24', '10.0.4.0/24']). Used for secure resources like Application Servers & Databases."
  type        = list(string)
}

variable "availability_zone" {
  description = "List of AWS Availability Zones where the subnets will be created (e.g., ['us-east-1a', 'us-east-1b'])."
  type        = list(string)
}

# ==========================================
# Route Table Configurations
# ==========================================

variable "public_rt_name" {
  description = "The Name tag for the Public Route Table, which routes traffic directly to the Internet Gateway."
  type        = string
}

variable "private_rt_name" {
  description = "The Name tag for the Private Route Table, which routes outbound traffic through the NAT Gateway."
  type        = string
}