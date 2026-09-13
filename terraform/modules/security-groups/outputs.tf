output "security_group_ids" {
  description = "Security group IDs"
  value = {
    for name, sg in aws_security_group.security_group : name => sg.id
  }
}