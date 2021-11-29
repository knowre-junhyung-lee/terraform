resource "aws_lb" "ecs-lb" {
  name               = "alb"
  subnets            = ["subnet-022a9999d2e062ad6", "subnet-0dbe1a80d4720162b"]
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]

#   access_logs {
#     bucket  = aws_s3_bucket.log_storage.id
#     prefix  = "frontend-alb"
#     enabled = true
#   }

}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = "arn:aws:acm:ap-northeast-2:799844212623:certificate/924180f0-94bd-4760-a230-7d25f4cc4eda" # aws_acm_certificate.cert.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-target.arn
  }
}


resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "ecs-target" {
  name        = "ecs-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0951f506e3fa4fb59" # aws_vpc.cluster_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    timeout             = 5
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}