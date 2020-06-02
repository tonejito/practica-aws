provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

################################################################################
# https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
# https://aws.amazon.com/marketplace/pp/B0859NK4HC
# https://us-west-2.console.aws.amazon.com/ec2/v2/home?region=us-west-2#Images:visibility=public-images;ownerAlias=136693071363;architecture=x86_64;sort=name

variable "aws_region" {
  default = "us-east-2" # Ohio
}

variable "aws_profile" {
  default = "ciencias"
}

variable "debian_release" {
  default = "buster"
}

variable "debian_aws_account" {
  # default = "379101102735" # stretch
  default = "136693071363" # buster
}

data "aws_ami" "debian_ami" {
  most_recent = true

  filter {
    name   = "name"
    # architecture = "x86_64"
    # values = ["debian-${var.debian_release}-hvm-x86_64-gp2-*"] # stretch
    values = ["debian-10-amd64-*"] # buster
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Debian
  owners = [var.debian_aws_account]
}

output aws_ami_name {
  value = data.aws_ami.debian_ami.name
}

output aws_ami_id {
  value = data.aws_ami.debian_ami.image_id
}

# TODO: Find Ubuntu AMI
