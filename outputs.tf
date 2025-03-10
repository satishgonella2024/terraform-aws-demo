output "vpc_id" {
  value = module.vpc.vpc_id
}

output "igw_id" {
  value = module.vpc.igw_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_app_subnets" {
  value = module.vpc.private_subnet_ids
}

output "private_db_subnets" {
  value = module.vpc.private_subnet_ids
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns
}

output "app_target_group_arn" {
  value = module.alb.alb_target_group_arn
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "bastion_host_id" {
  value = module.ec2.bastion_id
}

output "backend_server_id" {
  value = module.ec2.backend_id
}