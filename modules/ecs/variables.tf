# var.route53_zone_id
variable "route53_zone_id" {
  type = string
}

# var.domain_name
variable "domain_name" {
  type = string
}

# var.cluster_name
variable "cluster_name" {
  type = string
}

# var.service_name
variable "service_name" {
  type = string
}

# var.ecs_iam_role_name
variable "ecs_iam_role_name" {
  type = string
}

# var.task_json
variable "task_json" {
  type = string
}

# var.ecs_subnetid
variable "ecs_subnetids" {
  type = list(string)
}

# var.container_name
variable "container_name" {
  type = string
}

# var.container_port
variable "container_port" {
  type = string
}

# var.lb_subnetid
variable "lb_subnetids" {
  type = list(string)
}

# var.lb_name
variable "lb_name" {
  type = string
}

# var.acm_arn
variable "acm_arn" {
  type = string
}

# var.target_name
variable "target_name" {
  type = string
}

# var.vpcid
variable "vpcid" {
  type = string
}

# var.lb_sg_name
variable "lb_sg_name" {
  type = string
}

# var.ecs_sg_name
variable "ecs_sg_name" {
  type = string
}

# var.host_port
variable "host_port" {
  type = string
}
