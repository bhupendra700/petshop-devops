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

output "nat_addresses" {
  value = [
    for address in aws_nat_gateway.nat_gateway.regional_nat_gateway_address :
    address.public_ip
  ]
}