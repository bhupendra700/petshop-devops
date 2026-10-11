output "backend_secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  value       = data.aws_secretsmanager_secret.backend.arn
}