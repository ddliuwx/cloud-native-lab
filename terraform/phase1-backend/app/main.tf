terraform {
  required_version = ">= 1.5.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }

  backend "s3" {
    bucket         = "tf-state-ddliu2026"
    key            = "phase1-app/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-state-lock-ddliu2026"
    encrypt        = true
  }
}

resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "This state now lives in S3, not on my laptop! new add"
}