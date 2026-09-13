resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "target_group_for_alb" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http_front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_for_alb.arn
  }
}

resource "aws_alb_target_group_attachment" "ec2" {
  count = length(var.ec2_ids)

  target_group_arn = aws_lb_target_group.target_group_for_alb.arn
  target_id = var.ec2_ids[count.index]
  port = 80
}