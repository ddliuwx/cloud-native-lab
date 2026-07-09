resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning?1:0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.lifecycle_days != null ? 1: 0
  bucket = aws_s3_bucket.this.id

  rule {
    id = "expire-old-versions"
    status = "Enabled"
    filter {
      
    }
    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_days
    }
  }
}