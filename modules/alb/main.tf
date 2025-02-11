resource "aws_lb" "app_alb" {
  count = lookup(var.enable_alb, terraform.workspace, false) ? 1 : 0

  name               = "app-load-balancer-${terraform.workspace}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = lookup(var.public_subnet_ids, terraform.workspace, [])

  tags = {
    Name        = "app-alb-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_lb_target_group" "app_tg" {
  count    = lookup(var.enable_alb, terraform.workspace, false) ? 1 : 0
  name     = "app-target-group-${terraform.workspace}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = length(var.backend_instance_id) # ✅ Only attach if backend exists
  target_group_arn = aws_lb_target_group.app_tg[0].arn
  target_id        = var.backend_instance_id[count.index]
  port             = 80
}

resource "aws_lb_listener" "http_listener" {
  count             = lookup(var.enable_alb, terraform.workspace, false) ? 1 : 0
  load_balancer_arn = aws_lb.app_alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[0].arn
  }
}