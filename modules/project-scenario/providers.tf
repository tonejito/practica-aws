################################################################################
# https://www.terraform.io/docs/providers/aws/
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
