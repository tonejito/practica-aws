################################################################################
# https://www.terraform.io/docs/configuration/locals.html

locals {
  user_list = flatten(concat(["master"], var.equipos))
  # user_list = flatten(concat(["master"], lookup(var.equipo[count.index], "name")))
}
