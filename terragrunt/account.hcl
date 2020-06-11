# Set account-wide variables
# These are automatically pulled in to configure the remote state bucket in the
# root terragrunt.hcl configuration

locals {
  account_name   = "ciencias"
  aws_account_id = "374417498684"
  aws_profile    = "ciencias"
}
