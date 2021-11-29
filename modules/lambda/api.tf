resource "aws_api_gateway_rest_api" "lambda-svc" {
  name = var.api_gw_name
}

resource "aws_api_gateway_resource" "lambda-svc" {
  path_part   = var.api_path
  parent_id   = aws_api_gateway_rest_api.lambda-svc.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda-svc.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda-svc.id
  resource_id   = aws_api_gateway_resource.lambda-svc.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id   = aws_api_gateway_rest_api.lambda-svc.id
  resource_id   = aws_api_gateway_resource.lambda-svc.id
  http_method = aws_api_gateway_method.method.http_method

  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda-svc.id
  resource_id             = aws_api_gateway_resource.lambda-svc.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda-svc.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-svc.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.lambda-svc.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.lambda-svc.path}"
}

resource "aws_api_gateway_deployment" "lambda-svc" {
  rest_api_id = aws_api_gateway_rest_api.lambda-svc.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.lambda-svc.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda-svc" {
  deployment_id = aws_api_gateway_deployment.lambda-svc.id
  rest_api_id   = aws_api_gateway_rest_api.lambda-svc.id
  stage_name    = var.stage_name
}

resource "aws_api_gateway_domain_name" "lambda-svc" {
  certificate_arn = var.acm_arn
  domain_name     = var.domain_name
}

resource "aws_route53_record" "lambda-svc" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.route53_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.lambda-svc.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.lambda-svc.cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "lambda-svc" {
  api_id      = aws_api_gateway_rest_api.lambda-svc.id
  stage_name  = aws_api_gateway_stage.lambda-svc.stage_name
  domain_name = aws_api_gateway_domain_name.lambda-svc.domain_name
}