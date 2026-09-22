resource "aws_s3_bucket" "this" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name = var.s3_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  # Public bucket (App) ke liye false, Private (Ansible) ke liye true
  block_public_acls       = var.is_public ? false : true
  block_public_policy     = var.is_public ? false : true
  ignore_public_acls      = var.is_public ? false : true
  restrict_public_buckets = var.is_public ? false : true
}

# Sirf tabhi policy lagegi jab is_public = true hoga
resource "aws_s3_bucket_policy" "public_policy" {
  count  = var.is_public ? 1 : 0
  bucket = aws_s3_bucket.this.id

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
        Resource  = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}