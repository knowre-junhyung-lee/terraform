# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "3.66.0"
#     }
#   }

#    backend "remote" {
#     organization = "jhlee5391"
#     workspaces {
#       name = "ecs_service"
#     }
#   }
# }

provider "aws" {
  region     = "ap-northeast-2"
}

module "ecs" {
  source = "../../modules/ecs"
  cluster_name = "test_cluster"
  service_name = "http-ecs-service"
  route53_zone_id = "Z0117738I196EQRYPI0H"
  domain_name = "ecs.junhyung.knowre.com"
  acm_arn = "arn:aws:acm:ap-northeast-2:799844212623:certificate/924180f0-94bd-4760-a230-7d25f4cc4eda"
  vpcid = "vpc-0951f506e3fa4fb59"
  lb_name = "alb"
  ecs_subnetids = ["subnet-09dee0aac5bf7ec2b","subnet-0e90bbd9dec150c09"]
  lb_subnetids = ["subnet-022a9999d2e062ad6", "subnet-0dbe1a80d4720162b"]
  ecs_iam_role_name = "ecs_task_execution_role"
  lb_sg_name = "lb-sg"
  ecs_sg_name = "ecs-tasks-sg"
  task_json = file("./task.json")
  container_name = "http-server"
  container_port = 3000
  host_port = 3000
  target_name = "ecs-target"
}




