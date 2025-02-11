output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  value = terraform.workspace == "prod" ? aws_route_table.private_rt[0].id : null
}

output "nat_gateway_id" {
  value = terraform.workspace == "prod" ? aws_nat_gateway.nat_gateway[0].id : null
}