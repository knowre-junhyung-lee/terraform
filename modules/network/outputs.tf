output "vpc_id" {
  value = aws_vpc.main.id
}

output "public-1_subnet_id" {
  value = aws_subnet.public-1.id
}

output "private-1_subnet_id" {
  value = aws_subnet.private-1.id
}
