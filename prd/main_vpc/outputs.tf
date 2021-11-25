output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public-1_subnet_id" {
  value = module.vpc.public-1_subnet_id
}

output "private-1_subnet_id" {
  value = module.vpc.private-1_subnet_id
}

output "public-2_subnet_id" {
  value = module.vpc.public-2_subnet_id
}

output "private-2_subnet_id" {
  value = module.vpc.private-2_subnet_id
}