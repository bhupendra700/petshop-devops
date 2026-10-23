resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = var.s3_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.s3_bucket.id

  # Public bucket (App) ke liye false, Private (Ansible) ke liye true
  block_public_acls       = var.is_public ? false : true
  block_public_policy     = var.is_public ? false : true
  ignore_public_acls      = var.is_public ? false : true
  restrict_public_buckets = var.is_public ? false : true
}

resource "aws_s3_bucket_policy" "public_policy" {
  count  = var.is_public ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket.arn}/*"
      }
    ]
  })
}

//ECS s3 access permission role
resource "aws_iam_role" "app_s3_access" {
  name = "${var.project_name}-app-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "app_s3_access" {
  name = "${var.project_name}-app-s3-access-policy"
  role = aws_iam_role.app_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.s3_bucket.arn,
          "${aws_s3_bucket.s3_bucket.arn}/*"
        ]
      }
    ]
  })
}