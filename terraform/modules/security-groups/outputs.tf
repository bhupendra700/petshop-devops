output "alb_sg_id" {
  description = "Security Group ID of ALB"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = try(aws_security_group.ecs[0].id, null)
}

output "private_ec2_sg_id" {
  value = try(aws_security_group.ec2_sg[0].id, null)
}