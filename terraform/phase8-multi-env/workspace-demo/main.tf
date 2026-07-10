terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

module "bucket" {
  source      = "../../modules/s3-bucket"
  bucket_name = "${var.project_prefix}-${terraform.workspace}-demo-bucket"
}