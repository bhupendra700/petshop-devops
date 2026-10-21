variable "s3_bucket_name" {
  type = string
}

variable "is_public" {
  type    = bool
  default = false
}

variable "project_name" {
  type    = string
  default = "petshop"
}