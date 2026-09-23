output "vpc_id" {
  description = "The ID of the VPC created"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "alb_sg_id" {
  description = "Security group ID"
  value       = module.security_groups.alb_sg_id
}

output "private_ec2_sg_id" {
  description = "Security group ID"
  value       = module.security_groups.private_ec2_sg_id
}

output "private_ec2_private_ips" {
  description = "Private EC2 all private IP's"
  value       = module.ec2.private_ec2_private_ips
}

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = module.alb.alb_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = module.alb.target_group_arn
}

output "atlas_project_name" {
  value = data.mongodbatlas_project.petshop.name
}