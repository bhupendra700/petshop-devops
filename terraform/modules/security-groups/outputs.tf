output "alb_sg_id" {
  description = "Security Group ID of ALB"
  value       = aws_security_group.alb_sg.id
}

output "private_ec2_sg_id" {
  description = "Security Group ID of Private EC2"
  value       = aws_security_group.simple_petshot_private_ec2_sg.id
}