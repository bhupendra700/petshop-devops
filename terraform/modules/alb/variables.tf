variable "alb_security_group" {
  type = string
}

variable "public_subnet_ids" {
    type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ec2_ids" {
  type    = list(string)
  default = []
}

variable "domain_name" {
  type = string
}

variable "project_name" {
  type = string
}

variable "deployment_type" {
  type = string
}