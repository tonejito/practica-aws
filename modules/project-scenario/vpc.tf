################################################################################
# https://www.terraform.io/docs/providers/aws/r/security_group.html

resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Allow all traffic"
  vpc_id      = var.vpc_id
  tags        = merge({ "Name" = "allow_all_traffic" }, var.tags)
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
# TODO: Create SG rules in array

resource "aws_security_group_rule" "allow_all_ingress" {
  description       = "pass in all"
  type              = "ingress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_egress" {
  description       = "pass out all"
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.allow_all.id
}
