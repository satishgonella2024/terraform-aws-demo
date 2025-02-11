output "alb_dns" {
  value = length(aws_lb.app_alb) > 0 ? aws_lb.app_alb[0].dns_name : null
}

output "alb_target_group_arn" {
  value = length(aws_lb_target_group.app_tg) > 0 ? aws_lb_target_group.app_tg[0].arn : null
}