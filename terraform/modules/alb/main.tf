# 1. AWS Certificate Request
resource "aws_acm_certificate" "petshop" {
  domain_name       = "petshop.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# 2. Existing Route 53 Zone Fetching
data "aws_route53_zone" "main" {
  name = var.domain_name 
}

# 3. DNS Validation Record Create Karna
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.petshop.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id

  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

# 4. Certificate Validation Complete Hone Ka Wait
resource "aws_acm_certificate_validation" "petshop" {
  certificate_arn         = aws_acm_certificate.petshop.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 5. Application Load Balancer
resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

# 6. Target Group
resource "aws_lb_target_group" "target_group_for_alb" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# 7. HTTP Listener (Port 80 to 443 Redirect)
resource "aws_lb_listener" "http_front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# 8. HTTPS Listener (Port 443 with SSL)
resource "aws_lb_listener" "https_front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = aws_acm_certificate_validation.petshop.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_for_alb.arn
  }
}

# 9. Target Group Attachment (EC2 Instances)
resource "aws_alb_target_group_attachment" "ec2" {
  count            = length(var.ec2_ids)
  target_group_arn = aws_lb_target_group.target_group_for_alb.arn
  target_id        = var.ec2_ids[count.index]
  port             = 80
}

# 10. Route 53 A Record (Domain ko ALB se point karna)
resource "aws_route53_record" "alb_dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "petshop.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}