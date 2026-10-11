output "alb_sg_id" {
  description = "Security Group ID of ALB"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "private_ec2_sg_id" {
  description = "Security Group ID of Private EC2"
  value       = aws_security_group.ec2_sg.id
}