resource "aws_apigatewayv2_api" "hello" {
    name          = "ddliu-phase6-hello-api"
    protocol_type = "HTTP" 
}

resource "aws_apigatewayv2_integration" "hello" {
    api_id = aws_apigatewayv2_api.hello.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.hello.invoke_arn
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "hello" {
    api_id = aws_apigatewayv2_api.hello.id
    route_key = "GET /hello"
    target = "integrations/${aws_apigatewayv2_integration.hello.id}"
}

resource "aws_apigatewayv2_stage" "default" {
    api_id = aws_apigatewayv2_api.hello.id
    name = "$default"
    auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway" {
    statement_id = "AllowAPIGatewayInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.hello.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.hello.execution_arn}/*/*"
}