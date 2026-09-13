resource "aws_security_group" "security_group" {
  for_each = var.security_groups

  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = each.key
  }
}

resource "aws_security_group_rule" "alb_to_private_ec2" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = aws_security_group.security_group["simple_petshot_private_ec2_sg"].id
  source_security_group_id = aws_security_group.security_group["alb-sg"].id
}

resource "aws_security_group_rule" "public_ec2_to_private_ec2_with_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id        = aws_security_group.security_group["simple_petshot_private_ec2_sg"].id
  source_security_group_id = aws_security_group.security_group["simple_petshot_public_ec2_sg"].id
}