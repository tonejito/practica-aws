################################################################################
# https://www.terraform.io/docs/providers/aws/r/instance.html
# TODO: Add /64 ipv6_cidr_block to aws_subnet to use
# ipv6_address_count in aws_instance

resource "aws_instance" "ec2_instance" {
  count                   = length(var.equipo)
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = aws_key_pair.ssh_key.key_name
  ebs_optimized           = "true"
  monitoring              = "false"
  subnet_id               = var.subnet_id
  disable_api_termination = "true"
  vpc_security_group_ids  = [aws_security_group.allow_all.id]
  user_data               = "" # bootstrap from file
  tags                    = merge({ "Name" = var.equipo[count.index] }, var.tags)
  volume_tags             = merge({ "Name" = var.equipo[count.index] }, var.tags)
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip.html

resource "aws_eip" "elastic_ip" {
  count    = length(var.equipo)
  instance = aws_instance.ec2_instance[count.index].id
  vpc      = true
  tags     = merge({ "Name" = var.equipo[count.index] }, var.tags)
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip_association.html

resource "aws_eip_association" "elastic_ip_association" {
  count         = length(var.equipo)
  instance_id   = aws_instance.ec2_instance[count.index].id
  allocation_id = aws_eip.elastic_ip[count.index].id
}
