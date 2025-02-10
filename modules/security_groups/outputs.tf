output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "backend_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}