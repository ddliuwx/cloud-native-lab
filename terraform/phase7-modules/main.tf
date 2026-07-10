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

module "vpc" {
  source       = "../modules/vpc"
  project_name = "ddliu-phase7"
}

module "ec2" {
  source       = "../modules/ec2"
  project_name = "ddliu-phase7"
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnet_id
}

data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read_only" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.target_bucket_name}",
      "arn:aws:s3:::${var.target_bucket_name}/*",
    ]
  }

}

resource "aws_iam_policy" "s3_read_only" {
  name        = "ddliu-phase7-s3-readonly-policy"
  description = "Policy to allow read-only access to S3 bucket"
  policy      = data.aws_iam_policy_document.s3_read_only.json
}

module "ec2_s3_readonly_role" {
  source                  = "../modules/iam-role"
  role_name               = "ddliu-phase7-ec2-s3-readonly-role"
  assume_role_policy      = data.aws_iam_policy_document.ec2_trust.json
  managed_policy_arns     = [aws_iam_policy.s3_read_only.arn]
  create_instance_profile = true
}


resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_oidc_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_minimal" {
  statement {
    actions = ["s3:GetCallerIdentity"]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "github_actions_minimal" {
  name        = "ddliu-phase7-github-actions-minimal-policy"
  description = "Policy to allow minimal access for GitHub Actions"
  policy      = data.aws_iam_policy_document.github_actions_minimal.json
}

module "github_actions_role" {
  source                  = "../modules/iam-role"
  role_name               = "ddliu-phase7-github-actions-role"
  assume_role_policy      = data.aws_iam_policy_document.github_oidc_trust.json
  managed_policy_arns     = [aws_iam_policy.github_actions_minimal.arn]
  create_instance_profile = false
}

module "app_data_bucket" {
  source            = "../modules/s3-bucket"
  bucket_name       = "${var.project_prefix}-phase7-app-data"
  enable_versioning = true
  lifecycle_days    = 30
}


data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

module "lambda_role" {
  source              = "../modules/iam-role"
  role_name           = "ddliu-phase7-lambda-exec-role"
  assume_role_policy  = data.aws_iam_policy_document.lambda_trust.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}

module "hello_lambda" {
  source        = "../modules/lambda"
  function_name = "ddliu-phase7-hello-lambda"
  source_file   = "${path.module}/lambda_function.py"
  handler       = "lambda_function.handler"
  role_arn      = module.lambda_role.role_arn
}

module "database" {
  source     = "../modules/rds"
  identifier = "ddliu-phase7-db"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.public_subnet_id, module.vpc.public_subnet_b_id]
  my_ip      = var.my_ip
}