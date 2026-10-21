output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_id" {
  description = "The ID/Name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "app_s3_role_arn" {
  value = aws_iam_role.app_s3_access.arn
}

output "app_s3_role_name" {
  value = aws_iam_role.app_s3_access.name
}

output "app_instance_profile_name" {
  value = aws_iam_instance_profile.app.name
}