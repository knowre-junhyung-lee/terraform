terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.66.0"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-2"
}

module "vpc" {
  source                    = "../../modules/network"
  vpc_cidr_block            = "10.10.0.0/16"
  public-1_subnet_cidr_block  = "10.10.0.0/24"
  private-1_subnet_cidr_block = "10.10.1.0/24"
}
