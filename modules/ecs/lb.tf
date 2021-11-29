resource "aws_lb" "ecs-lb" {
  name               = var.lb_name
  subnets            = var.lb_subnetids
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
  certificate_arn   = var.acm_arn
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
  name        = var.target_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpcid
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