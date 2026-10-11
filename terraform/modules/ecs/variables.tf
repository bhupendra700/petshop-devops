variable "project_name" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "nginx_image" {
  type = string
  default = "nginx:latest"
}

variable "frontend_image" {
  type = string
  default = "alphine:latest"
}

variable "backend_image" {
  type = string
  default = "alpine:latest"
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