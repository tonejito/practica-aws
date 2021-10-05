################################################################################
# https://www.terraform.io/docs/providers/aws/r/instance.html
# TODO: Add /64 ipv6_cidr_block to aws_subnet to use
# ipv6_address_count in aws_instance
#
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/installing-cloudwatch-agent-commandline.html
# TODO: Install and configure CloudWatch Agent to get memory and OS metrics
#
# Turn off "disable_api_termination" before deleting the EC2 instance
# aws ec2 describe-instance-attribute --instance-id ${INSTANCE_ID} --attribute disableApiTermination
# aws ec2 modify-instance-attribute --instance-id ${INSTANCE_ID} --no-disable-api-termination

resource "aws_instance" "ec2_instance" {
  count                   = length(var.equipo)
  ami                     = lookup(var.equipo[count.index], "ami_id")
  instance_type           = lookup(var.equipo[count.index], "instance_type")
  iam_instance_profile    = aws_iam_instance_profile.iam_instance_profile.id
  key_name                = aws_key_pair.ssh_key.key_name
  ebs_optimized           = "false" # "true"
  monitoring              = "false"
  subnet_id               = var.subnet_id
  disable_api_termination = "true"
  vpc_security_group_ids  = [aws_security_group.allow_all.id]
  root_block_device {
    volume_size = var.root_volume_size
  }
  user_data   = "" # bootstrap from file
  tags        = merge({ "Name" = lookup(var.equipo[count.index], "name") }, var.tags)
  volume_tags = merge({ "Name" = lookup(var.equipo[count.index], "name") }, var.tags)
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip.html

resource "aws_eip" "elastic_ip" {
  count    = length(var.equipo)
  instance = aws_instance.ec2_instance[count.index].id
  vpc      = true
  tags     = merge({ "Name" = lookup(var.equipo[count.index], "name") }, var.tags)
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip_association.html

resource "aws_eip_association" "elastic_ip_association" {
  count         = length(var.equipo)
  instance_id   = aws_instance.ec2_instance[count.index].id
  allocation_id = aws_eip.elastic_ip[count.index].id
}
