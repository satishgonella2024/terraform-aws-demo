output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.learning_vpc_01.id
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.learning_igw_01.id
}

# Outputs for Public Subnets
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public_subnets[*].id
}

# Outputs for Private Subnets
output "private_app_subnets" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_app_subnets[*].id
}

# Outputs for Private DB Subnets
output "private_db_subnets" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private_db_subnets[*].id
}

# Outputs for Public Route Table
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public_rt.id
}

# Outputs for Private Route Table
output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private_rt.id
}

output "app_target_group_arn" {
  description = "The ARN of the ALB Target Group"
  value       = aws_lb_target_group.app_target_group.arn
}