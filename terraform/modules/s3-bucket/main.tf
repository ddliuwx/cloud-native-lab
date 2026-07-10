terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
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
  count  = var.lifecycle_days != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"
    filter {

    }
    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_days
    }
  }

  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"
    filter {

    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}