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
      name = "ecs_service"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-2"
}
