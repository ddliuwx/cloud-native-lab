terraform {
  required_providers {
    aws={
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    archive={
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  } 
}

provider "aws" {
  region = "ap-southeast-2"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
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

resource "aws_iam_role" "lambda_exec" {
    name               = "ddliu-phase6-lambda_exec_role"
    assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}


resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello" {
  function_name = "ddliu-phase6-hello-lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}