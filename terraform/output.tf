output "ec2_public_ip" {
  description = "Public IP address of Petshop EC2"
  value       = aws_instance.simple_petshop_ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of Petshop EC2"
  value       = aws_instance.simple_petshop_ec2.public_dns
}

output "vpc_id" {
  description = "ID of the Petshop VPC"
  value       = aws_vpc.simple_petshop_vpc.id
}

output "subnet_id" {
  description = "ID of the Petshop Public Subnet"
  value       = aws_subnet.simple_petshop_public_subnet.id
}