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
      name = "cloudfront_service"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-2"
}

module "cloudfront" {
  source = "../../modules/cloudfront"
  bucket_name = "junhyung-test-web"
  route53_zone_id = "Z0117738I196EQRYPI0H"
  domain_name = "www.junhyung.knowre.com"
  acm_arn = "arn:aws:acm:us-east-1:799844212623:certificate/0f49dbdb-8311-45c5-b4b9-5625e222b3a9"
}


