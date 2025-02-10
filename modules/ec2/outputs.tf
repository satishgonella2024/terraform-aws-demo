output "bastion_id" {
  value = aws_instance.bastion.id
}

output "backend_id" {
  value = aws_instance.backend.id
}