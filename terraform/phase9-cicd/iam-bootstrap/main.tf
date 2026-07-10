terraform {
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
    # this time scoped precisely to pushes on main and any PR, not "*" for the whole repo like Phase 4
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repo}:ref:refs/heads/main",
        "repo:${var.github_repo}:pull_request",
      ]
    }
  }
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    actions = [
      "s3:GetBucket*",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetEncryptionConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetBucketVersioning",
    ]

    resources = [
      "arn:aws:s3:::${var.project_prefix}-phase9-ci-demo",
      "arn:aws:s3:::${var.project_prefix}-phase9-ci-demo/*",
    ]
  }
}

resource "aws_iam_policy" "ci_permissions" {
  name   = "ddliu-phase9-ci-permissions"
  policy = data.aws_iam_policy_document.ci_permissions.json
}

module "github_actions_role" {
  source                  = "../../modules/iam-role"
  role_name               = "ddliu-phase9-github-actions-role"
  assume_role_policy      = data.aws_iam_policy_document.github_oidc_trust.json
  managed_policy_arns     = [aws_iam_policy.ci_permissions.arn]
  create_instance_profile = false
}