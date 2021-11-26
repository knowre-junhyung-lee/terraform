variable "myregion" {
    type = string
    default = "ap-northeast-2"
}

variable "accountId" {
    type = string
    default = "799844212623"
}

resource "aws_api_gateway_rest_api" "lambda-svc" {
  name = "lambda-svc"
}

resource "aws_api_gateway_resource" "lambda-svc" {
  path_part   = "lambda-svc"
  parent_id   = aws_api_gateway_rest_api.lambda-svc.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda-svc.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.lambda-svc.id
  resource_id   = aws_api_gateway_resource.lambda-svc.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda-svc.id
  resource_id             = aws_api_gateway_resource.lambda-svc.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda-svc.invoke_arn
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-svc.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.lambda-svc.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.lambda-svc.path}"
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
  stage_name    = "lambda-svc"
}

resource "aws_api_gateway_domain_name" "lambda-svc" {
  certificate_arn = "arn:aws:acm:us-east-1:799844212623:certificate/0f49dbdb-8311-45c5-b4b9-5625e222b3a9" # aws_acm_certificate.cert.arn
  domain_name     = "lambda.junhyung.knowre.com"
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
resource "aws_route53_record" "lambda-svc" {
  name    = "lambda.junhyung.knowre.com"
  type    = "A"
  zone_id = "Z0117738I196EQRYPI0H"

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