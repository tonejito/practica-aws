provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

################################################################################
# Amazon Linux 2

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=amazon;platform=amazonlinux;architecture=x86_64;imageId=ami-00dfe2c7ce89a450b;sort=desc:imageId
# amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2
variable "ami_amazon-linux_2_amd64" {
  default = "ami-00dfe2c7ce89a450b"
}

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=amazon;platform=amazonlinux;architecture=arm64;imageId=ami-031dea1a744251b51;sort=desc:imageId
# amzn2-ami-hvm-2.0.20210813.1-arm64-gp2
variable "ami_amazon-linux_2_arm64" {
  default = "ami-031dea1a744251b51"
}


################################################################################
# Ubuntu 20.04 LTS focal
# https://cloud-images.ubuntu.com/locator/ec2/

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=099720109477;platform=ubuntu;architecture=x86_64;imageId=ami-0ac4906b9504bec77;sort=desc:imageId
# ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210927
variable "ami_ubuntu_20-04_amd64" {
  default = "ami-0ac4906b9504bec77"
}

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=099720109477;platform=ubuntu;architecture=arm64;imageId=ami-0280c148473619d48;sort=desc:imageId
# ubuntu/images/hvm-ssd/ubuntu-focal-20.04-arm64-server-20210927
variable "ami_ubuntu_20-04_arm64" {
  default = "ami-0280c148473619d48"
}

################################################################################
# https://wiki.centos.org/Cloud/AWS#Images
# CentOS 8 Stream

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=125523088429;platform=centOS;architecture=x86_64;imageId=ami-045b0a05944af45c1;sort=desc:imageId
# CentOS Stream 8 x86_64 20210603
variable "ami_centos_8_stream_amd64" {
  default = "ami-045b0a05944af45c1"
}

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=125523088429;platform=centOS;architecture=arm64;imageId=ami-01cdc9e8306344fe0;sort=desc:imageId
# CentOS Stream 8 aarch64 20210603
variable "ami_centos_8_stream_arm64" {
  default = "ami-01cdc9e8306344fe0"
}

# CentOS 7
# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=125523088429;platform=centOS;architecture=x86_64;imageId=ami-00f8e2c955f7ffa9b;sort=desc:imageId
# CentOS 7.9.2009 x86_64
variable "ami_centos_7_amd64" {
  default = "ami-00f8e2c955f7ffa9b"
}

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=125523088429;platform=centOS;architecture=arm64;imageId=ami-07f692d95b2b9c8c5;sort=desc:imageId
# CentOS 7.9.2009 aarch64
variable "ami_centos_7_arm64" {
  default = "ami-07f692d95b2b9c8c5"
}

################################################################################
# https://wiki.debian.org/Cloud/AmazonEC2Image/Bullseye
# https://aws.amazon.com/marketplace/pp/B0859NK4HC
# Debian 11 bullseye

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=136693071363;platform=debian;architecture=x86_64;imageId=ami-0e8fd6430077f7450;sort=desc:imageId
# debian-11-amd64-20210928-779
variable "ami_debian_11_amd64" {
  default = "ami-0e8fd6430077f7450"
}

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=136693071363;platform=debian;architecture=arm64;imageId=ami-05072f33892a49012;sort=desc:imageId
# debian-11-arm64-20210928-779
variable "ami_debian_11_arm64" {
  default = "ami-05072f33892a49012"
}

################################################################################
# https://wiki.debian.org/Cloud/AmazonEC2Image/Buster
# https://aws.amazon.com/marketplace/pp/B0859NK4HC
# Debian 10 buster

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=136693071363;platform=debian;architecture=x86_64;imageId=ami-07640f3f27c0ad3d3;sort=desc:imageId
# debian-10-amd64-20210721-710
variable "ami_debian_10_amd64" {
  default = "ami-07640f3f27c0ad3d3"
}

# https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2#Images:visibility=public-images;ownerAlias=136693071363;platform=debian;architecture=arm64;imageId=ami-060544b8209ee8136;sort=desc:imageId
# debian-10-arm64-20210721-710
variable "ami_debian_10_arm64" {
  default = "ami-060544b8209ee8136"
}

variable "aws_region" {
  default = "us-east-2" # Ohio
}

variable "aws_profile" {
  default = "ciencias"
}




##

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
