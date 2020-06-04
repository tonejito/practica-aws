################################################################################
# https://www.terraform.io/docs/configuration/locals.html

locals {
  user_list = flatten(concat(["master"], var.equipo))
}
