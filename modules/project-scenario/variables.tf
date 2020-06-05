################################################################################

variable "aws_region" {}

variable "aws_profile" {
  default = "default"
}

variable "name" {}

variable "vpc_id" {}

variable "subnet_id" {}

variable "ami_id" {}

variable "root_volume_size" {
  default = "10"
}

variable "instance_type" {}

variable "dns_domain" {}

# variable "dns_zone_id" {}

variable "ssh_key_file" {}

variable "key_name" {}

variable "iam_path" {
  default = "/"
}

variable "tags" {
  type = map

  default = {
    Terraform = "True"
  }
}

variable "equipo" {
  type = list(string)
}

variable "extra_iam_policies" {
  type = list(string)
}

variable "s3_website_content" {
  type = list(map(string))
}
