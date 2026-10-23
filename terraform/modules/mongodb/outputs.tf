# output "connection_string" {
#   value = format(
#     "mongodb+srv://%s:%s@%s/petshop",
#     urlencode(var.database_username),
#     urlencode(var.database_password),
#     trimprefix(
#       mongodbatlas_advanced_cluster.this.connection_strings.standard_srv,
#       "mongodb+srv://"
#     )
#   )

#   sensitive = true
# }

output "backend_secret_arn" {
  description = "The ARN of the Secrets Manager secret"
  value       = data.aws_secretsmanager_secret.backend.arn
}