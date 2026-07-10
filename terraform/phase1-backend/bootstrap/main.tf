terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# S3 bucket to strore terraform state file
resource "aws_s3_bucket" "tf_state" {
  bucket        = "tf-state-${var.unique_suffix}"
  force_destroy = true
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# encryption at rest - best practice to enable server-side encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "tf-state-lock-${var.unique_suffix}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

variable "unique_suffix" {
  description = "suffix to avoid global bucket name collision"
  type        = string
  default     = "ddliu2026"
}

output "bucket_name" {
  value = aws_s3_bucket.tf_state.id
}

output "aws_dynamodb_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}
