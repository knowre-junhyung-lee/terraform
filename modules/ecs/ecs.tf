resource "aws_route53_record" "http-ecs-domain" {
  zone_id = var.route53_zone_id
  name = var.domain_name
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
  name               = var.ecs_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "http-task" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = var.task_json
}

resource "aws_ecs_cluster" "http-ecs-cluster" {
  name = var.cluster_name
}

resource "aws_ecs_service" "http-ecs-service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.http-ecs-cluster.id
  task_definition = aws_ecs_task_definition.http-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.ecs_subnetids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-target.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.https_forward, aws_lb_listener.http_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

}