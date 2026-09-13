output "private_ec2_ids" {
  description = "Bane hue saare Private EC2 Instances ki IDs"
  value       = aws_instance.private_ec2[*].id
}

output "private_ec2_private_ips" {
  description = "Private EC2 Instances ke IP addresses"
  value       = aws_instance.private_ec2[*].private_ip
}

output "public_ec2_ids" {
  description = "Public EC2 Instances ki ID"
  value       = aws_instance.public_ec2.id
}

output "public_ec2_public_ips" {
  description = "Public EC2 Instances ke IP address"
  value       = aws_instance.public_ec2.public_ip
}