resource "aws_security_group" "lb" {
  vpc_id =  "vpc-0951f506e3fa4fb59" # aws_vpc.cluster_vpc.id
  name   = "lb-sg"
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  vpc_id = "vpc-0951f506e3fa4fb59" # aws_vpc.cluster_vpc.id
  name   = "ecs-tasks-sg"

  ingress {
    protocol        = "tcp"
    from_port       = 3000 # var.host_port
    to_port         = 3000 # var.container_port
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}