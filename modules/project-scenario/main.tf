# https://gitlab.com/Redes-Ciencias-UNAM/redes-ciencias-unam.gitlab.io/blob/master/public/laboratorio/practica7/practica7.pdf
# TODO: Execute this from the secondary account with AWS profiles / AssumeRole

################################################################################
# https://www.terraform.io/docs/providers/random/r/id.html

resource "random_id" "id" {
  byte_length = 8
  prefix      = ""
}
