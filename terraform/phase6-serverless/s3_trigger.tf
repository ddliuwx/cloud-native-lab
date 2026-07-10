resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project_prefix}-phase6-uploads"
}

data "archive_file" "s3_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_s3_handler.py"
  output_path = "${path.module}/lambda_s3_handler.zip"
}

resource "aws_lambda_function" "process_upload" {
  function_name    = "${var.project_prefix}-phase6-process-upload-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_s3_handler.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.s3_lambda_zip.output_path
  source_code_hash = data.archive_file.s3_lambda_zip.output_base64sha256

}


resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_upload.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.uploads.arn

}

resource "aws_s3_bucket_notification" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_upload.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
