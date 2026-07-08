
output "function_name" {
  value = aws_lambda_function.hello.function_name
}

output "function_arn" {
  value = aws_lambda_function.hello.arn
}

output "invoke_arn" {
  value = aws_lambda_function.hello.invoke_arn
}

output "api_endpoint" {
  value = aws_apigatewayv2_stage.default.invoke_url
}