terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
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

resource "aws_iam_role" "ec2_s3_readonly" {
  name               = "ec2-s3-readonly-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

data "aws_iam_policy_document" "s3_readonly" {
  statement {
    actions   = ["s3:GetObject", "s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.s3_target_bucket_name}",
      "arn:aws:s3:::${var.s3_target_bucket_name}/*"]
  }
}

resource "aws_iam_policy" "s3_readonly" {
  name        = "ec2-s3-readonly-policy"
  description = "Policy to allow read-only access to a specific S3 bucket"
  policy      = data.aws_iam_policy_document.s3_readonly.json

}

resource "aws_iam_role_policy_attachment" "ec2_s3_readonly" {
  role = aws_iam_role.ec2_s3_readonly.name
  policy_arn = aws_iam_policy.s3_readonly.arn
}

resource "aws_iam_instance_profile" "ec2_s3_readonly" {
  name = "ec2-s3-readonly-profile"
  role = aws_iam_role.ec2_s3_readonly.name

}