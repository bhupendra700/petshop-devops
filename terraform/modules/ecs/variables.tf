variable "project_name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "nginx_image" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "backend_image" {
  type = string
}

variable "backend_secret_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}