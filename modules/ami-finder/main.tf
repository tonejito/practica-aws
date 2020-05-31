################################################################################
# https://www.terraform.io/docs/providers/aws/r/instance.html
# https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch

data "aws_ami" "debian_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Debian
  owners = ["379101102735"]
}

# TODO: Find Ubuntu AMI
