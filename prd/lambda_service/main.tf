terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.66.0"
    }
  }

   backend "remote" {
    organization = "jhlee5391"
    workspaces {
      name = "lambda_service"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-2"
}

module "lambda" {
  source = "../../modules/lambda"
  region = "ap-northeast-2"
  accountId = "799844212623"
  api_gw_name = "lambda-svc"
  api_path = "lambda-svc"
  stage_name = "lambda-svc"
  acm_arn = "arn:aws:acm:us-east-1:799844212623:certificate/0f49dbdb-8311-45c5-b4b9-5625e222b3a9"
  domain_name = "lambda.junhyung.knowre.com"
  route53_zone_id = "Z0117738I196EQRYPI0H"
  lambda_iam_role_name = "iam_role_lambda_function"
  lambda_logging_iam_policy_name = "iam_policy_lambda_logging_function"
  filename = "./index.zip"
  lambda_name = "lambda-svc"
  lambda_handler_name = "index.handler"
  lambda_runtime = "nodejs14.x"
}







