# https://gitlab.com/Redes-Ciencias-UNAM/redes-ciencias-unam.gitlab.io/blob/master/public/laboratorio/practica7/practica7.pdf

variable "name" {
  default = ""
}

variable "dns_domain" {}

variable "dns_zone_id" {}

variable "mysql_pw" {}

variable "tags" {
  type = "map"

  default = {
    Proyecto    = "Practica 7"
    Integrantes = "Andres Hernandez"
    Materia     = "Redes"
    Semestre    = "2019-2"
  }
}

################################################################################
# https://www.terraform.io/docs/providers/aws/
provider "aws" {
  region = "us-east-1"
}

################################################################################
# https://www.terraform.io/docs/providers/random/r/id.html

resource "random_id" "id" {
  byte_length = 8
  prefix      = ""
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/route53_zone.html

# resource "aws_route53_zone" "dns_zone" {
#   name = "${var.dns_domain}"
# }

################################################################################
# https://www.terraform.io/docs/providers/aws/r/key_pair.html

# $ mkdir -vp ~/.ssh/keys
# $ chmod 0700 ~/.ssh/keys
# $ ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/keys/aws-ciencias_rsa -C "andres.hernandez@ciencias.unam.mx"

resource "aws_key_pair" "ssh_key" {
  key_name = "aws-ciencias_rsa"

  # public_key = "ssh-rsa ... email@example.com"
  public_key = "${file("~/.ssh/keys/aws-ciencias_rsa.pub")}"
}

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

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.debian_ami.id}"
  instance_type = "t3a.nano"

  tags = "${var.tags}"
}

resource "aws_instance" "mail" {
  ami           = "${data.aws_ami.debian_ami.id}"
  instance_type = "t3a.nano"

  tags = "${var.tags}"
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip.html

resource "aws_eip" "web_eip" {
  instance = "${aws_instance.web.id}"
  vpc      = true
}

resource "aws_eip" "mail_eip" {
  instance = "${aws_instance.mail.id}"
  vpc      = true
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip_association.html

resource "aws_eip_association" "web_eip_assoc" {
  instance_id   = "${aws_instance.web.id}"
  allocation_id = "${aws_eip.web_eip.id}"
}

resource "aws_eip_association" "mail_eip_assoc" {
  instance_id   = "${aws_instance.mail.id}"
  allocation_id = "${aws_eip.mail_eip.id}"
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/db_instance.html

resource "aws_db_instance" "mysql_rds" {
  allocated_storage         = 20
  deletion_protection       = false
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "5.7"
  instance_class            = "db.t3.micro"
  name                      = "mydb"
  username                  = "master"
  password                  = "${var.mysql_pw}"
  parameter_group_name      = "default.mysql5.7"
  final_snapshot_identifier = "mysql-rds-${random_id.id.hex}"
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/route53_record.html

resource "aws_route53_record" "_" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "web.${var.dns_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.web_eip.public_ip}"]
}

resource "aws_route53_record" "www" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "www.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_route53_record._.name}"]
}

resource "aws_route53_record" "mail" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "mail.${var.dns_domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.mail_eip.public_ip}"]
}

resource "aws_route53_record" "mx" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "${var.dns_domain}"
  type    = "MX"
  ttl     = "300"
  records = ["1 ${aws_route53_record.mail.name}"]
}

resource "aws_route53_record" "spf" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "${var.dns_domain}"
  type    = "SPF"
  ttl     = "300"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
}

resource "aws_route53_record" "smtp" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "smtp.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_route53_record.mail.name}"]
}

resource "aws_route53_record" "imap" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "imap.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_route53_record.mail.name}"]
}

resource "aws_route53_record" "db" {
  # zone_id = "${aws_route53_zone.dns_zone.zone_id}"
  zone_id = "${var.dns_zone_id}"
  name    = "db.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.mysql_rds.address}"]
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
# https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html

resource "aws_s3_bucket" "backups_s3" {
  bucket = "s3-${random_id.id.hex}.${var.dns_domain}"
  acl    = "private"

  tags = "${var.tags}"
}

# ################################################################################
# # https://www.terraform.io/docs/providers/aws/r/ses_domain_identity.html
#
# resource "aws_ses_domain_identity" "example" {
#   domain = "example.com"
# }
#
# resource "aws_route53_record" "example_amazonses_verification_record" {
#   zone_id = "ABCDEFGHIJ123"
#   name    = "_amazonses.example.com"
#   type    = "TXT"
#   ttl     = "600"
#   records = ["${aws_ses_domain_identity.example.verification_token}"]
# }
#
# ################################################################################
# # https://www.terraform.io/docs/providers/aws/r/ses_domain_identity_verification.html
#
# resource "aws_ses_domain_identity" "example" {
#   domain = "example.com"
# }
#
# resource "aws_route53_record" "example_amazonses_verification_record" {
#   zone_id = "${aws_route53_zone.example.zone_id}"
#   name    = "_amazonses.${aws_ses_domain_identity.example.id}"
#   type    = "TXT"
#   ttl     = "600"
#   records = ["${aws_ses_domain_identity.example.verification_token}"]
# }
#
# resource "aws_ses_domain_identity_verification" "example_verification" {
#   domain = "${aws_ses_domain_identity.example.id}"
#
#   depends_on = ["aws_route53_record.example_amazonses_verification_record"]
# }
#
# ################################################################################
# # https://www.terraform.io/docs/providers/aws/r/ses_domain_dkim.html
#
# resource "aws_ses_domain_identity" "example" {
#   domain = "example.com"
# }
#
# resource "aws_ses_domain_dkim" "example" {
#   domain = "${aws_ses_domain_identity.example.domain}"
# }
#
# resource "aws_route53_record" "example_amazonses_verification_record" {
#   count   = 3
#   zone_id = "ABCDEFGHIJ123"
#   name    = "${element(aws_ses_domain_dkim.example.dkim_tokens, count.index)}._domainkey.example.com"
#   type    = "CNAME"
#   ttl     = "600"
#   records = ["${element(aws_ses_domain_dkim.example.dkim_tokens, count.index)}.dkim.amazonses.com"]
# }
#
# ################################################################################
# # https://www.terraform.io/docs/providers/aws/r/ses_domain_mail_from.html
#
# resource "aws_ses_domain_mail_from" "example" {
#   domain           = "${aws_ses_domain_identity.example.domain}"
#   mail_from_domain = "bounce.${aws_ses_domain_identity.example.domain}"
# }
#
# # Example SES Domain Identity
# resource "aws_ses_domain_identity" "example" {
#   domain = "example.com"
# }
#
# # Example Route53 MX record
# resource "aws_route53_record" "example_ses_domain_mail_from_mx" {
#   zone_id = "${aws_route53_zone.example.id}"
#   name    = "${aws_ses_domain_mail_from.example.mail_from_domain}"
#   type    = "MX"
#   ttl     = "600"
#   records = ["10 feedback-smtp.us-east-1.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.example` is created
# }
#
# # Example Route53 TXT record for SPF
# resource "aws_route53_record" "example_ses_domain_mail_from_txt" {
#   zone_id = "${aws_route53_zone.example.id}"
#   name    = "${aws_ses_domain_mail_from.example.mail_from_domain}"
#   type    = "TXT"
#   ttl     = "600"
#   records = ["v=spf1 include:amazonses.com -all"]
# }
