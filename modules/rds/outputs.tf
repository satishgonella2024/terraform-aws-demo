output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}