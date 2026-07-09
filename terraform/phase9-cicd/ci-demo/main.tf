terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

module "ci_demo_bucket" {
  source = "../../modules/s3-bucket"
  bucket_name = "dliu2026-phase9-ci-demo"
  version = false
}