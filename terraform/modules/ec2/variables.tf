variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "ec2_name" {
  type = list(string)
}

variable "s3_bucket_arn" {
  type = string
}