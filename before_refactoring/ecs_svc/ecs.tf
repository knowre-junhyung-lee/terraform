resource "aws_route53_record" "http-ecs-domain" {
  zone_id = "Z0117738I196EQRYPI0H" # data.aws_route53_zone.knowreinc.zone_id
  name = "ecs.junhyung.knowre.com"
  type = "A"

  alias {
    name                   = aws_lb.ecs-lb.dns_name
    zone_id                = aws_lb.ecs-lb.zone_id
    evaluate_target_health = true
  }
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# data "template_file" "task" {
#   template = file(var.tpl_path)
#   vars = {
#     region             = var.region
#     aws_ecr_repository = aws_ecr_repository.repo.repository_url
#     tag                = "latest"
#     container_port     = var.container_port
#     host_port          = var.host_port
#     app_name           = var.app_name
#   }
# }

resource "aws_ecs_task_definition" "http-task" {
  family                   = "http-ecs-service"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./task.json") # data.template_file.service.rendered
}

resource "aws_ecs_cluster" "http-ecs-cluster" {
  name = "http-ecs-cluster"
}

resource "aws_ecs_service" "http-ecs-service" {
  name            = "http-ecs-service"
  cluster         = aws_ecs_cluster.http-ecs-cluster.id
  task_definition = aws_ecs_task_definition.http-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = ["subnet-09dee0aac5bf7ec2b","subnet-0e90bbd9dec150c09"] # aws_subnet.cluster[*].id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-target.arn
    container_name   = "http-server"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.https_forward, aws_lb_listener.http_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

}