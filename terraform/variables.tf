variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket used for storing application media and images"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the resources will be deployed (e.g., us-east-1)"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID for authenticating Terraform with AWS"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Access Key for authenticating Terraform with AWS"
  sensitive   = true
}

variable "jwt_secret" {
  type        = string
  description = "Secret key used for signing and verifying JWT authentication tokens"
  sensitive   = true
}

variable "paypal_client" {
  type        = string
  description = "Client ID for PayPal payment gateway integration"
}

variable "admin_name" {
  type        = string
  description = "Default admin user name for the application"
}

variable "admin_email" {
  type        = string
  description = "Default admin email address used for login"
}

variable "admin_password" {
  type        = string
  description = "Default admin account password"
  sensitive   = true
}