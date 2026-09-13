variable "private_instance_type" {
  type = string
}

variable "public_instance_type" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "private_instance_security_group_id" {
  type = string
}

variable "public_instance_security_group_id" {
  type = string
}

variable "private_ec2_name" {
  type = string
}

variable "public_ec2_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}