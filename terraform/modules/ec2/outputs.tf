output "private_ec2_instance_ids" {
  description = "Bane hue saare Private EC2 Instances ki IDs"
  value = aws_instance.private_ec2[*].id
}

output "private_ec2_private_ips" {
  description = "Private EC2 Instances ke IP addresses"
  value       = aws_instance.private_ec2[*].private_ip
}