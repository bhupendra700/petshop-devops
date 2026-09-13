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

output "security_group_ids" {
  description = "Security group IDs"
  value       = module.security_groups.security_group_ids
}

output "private_ec2_private_ips" {
  description = "Private EC2 all private IP's"
  value       = module.ec2.private_ec2_private_ips
}

output "public_ec2_private_ips" {
  description = "Public EC2 public IP"
  value       = module.ec2.public_ec2_public_ips
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

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = var.s3_bucket_name
}