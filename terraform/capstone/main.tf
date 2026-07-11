terraform {
  required_version = ">=1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "tf-state-ddliu2026-capstone"
    key            = "capstone/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-state-lock-ddliu2026-capstone"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

module "vpc" {
  source       = "../modules/vpc"
  project_name = "ddliu2026-capstone"

}



