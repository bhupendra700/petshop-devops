output "vpc_id" {
  description = "The ID of the VPC created"
  value       = aws_vpc.petshop_vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "nat_eip" {
  value = aws_nat_gateway.nat_gateway.public_ip
}