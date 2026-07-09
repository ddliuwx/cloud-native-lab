data "archive_file" "this" {
  type = "zip"
  source_file = var.source_file
  output_path = "${path.module}/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role = var.role_arn
  handler = var.handler
  runtime = var.runtime
  filename = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256
}