data "aws_secretsmanager_secret" "backend" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "backend" {
  secret_id = data.aws_secretsmanager_secret.backend.id
}

resource "aws_secretsmanager_secret_version" "backend" {
  secret_id = data.aws_secretsmanager_secret.backend.id

  secret_string = jsonencode(
    merge(
      jsondecode(data.aws_secretsmanager_secret_version.backend.secret_string),
      {
        MONGO_URI = var.mongodb_uri
      }
    )
  )
}