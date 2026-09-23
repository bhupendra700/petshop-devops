variable "mongodb_atlas_public_key" {
  type      = string
  sensitive = true
}

variable "mongodb_atlas_private_key" {
  type      = string
  sensitive = true
}

variable "atlas_project_id" {
  type = string
}

variable "mongodb_database_username" {
  type      = string
  sensitive = true
}

variable "mongodb_database_password" {
  type      = string
  sensitive = true
}