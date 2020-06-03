# https://gitlab.com/Redes-Ciencias-UNAM/redes-ciencias-unam.gitlab.io/blob/master/public/laboratorio/practica7/practica7.pdf

# TODO: Execute this from the secondary account with AWS profiles / AssumeRole

variable "aws_region" {}

variable "aws_profile" {
  default = "default"
}

variable "name" {}

variable "vpc_id" {}

variable "subnet_id" {}

variable "ami_id" {}

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

################################################################################
# https://www.terraform.io/docs/providers/aws/
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

################################################################################
#
# https://www.terraform.io/docs/backends/types/s3.html

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

################################################################################
# https://www.terraform.io/docs/providers/random/r/id.html

resource "random_id" "id" {
  byte_length = 8
  prefix      = ""
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
# https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html
# TODO: Rename this and import it

resource "aws_s3_bucket" "s3_state" {
  bucket = "s3-${var.name}.${var.dns_domain}"
  acl    = "private"
  tags   = var.tags
  versioning {
    enabled = true
  }
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/key_pair.html

# $ mkdir -vp ~/.ssh/keys
# $ chmod 0700 ~/.ssh/keys
# $ ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/keys/aws-ciencias_rsa -C "andres.hernandez@ciencias.unam.mx"

resource "aws_key_pair" "ssh_key" {
  key_name = "${var.key_name}-${random_id.id.hex}"
  tags = var.tags

  # public_key = "ssh-rsa ... email@example.com"
  public_key = file("${var.ssh_key_file}")
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_group.html

resource "aws_iam_group" "iam_group" {
  name = "${var.name}-${random_id.id.hex}"
  path = var.iam_path
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_group_membership.html

resource "aws_iam_group_membership" "iam_group_membership" {
  name = "${var.name}-${random_id.id.hex}"
  group = aws_iam_group.iam_group.name
  users = flatten([
    aws_iam_user.iam_user_master.name,
    aws_iam_user.iam_user.*.name,
  ])
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_user.html

resource "aws_iam_user" "iam_user_master" {
  name = "${var.name}-${random_id.id.hex}"
  path = var.iam_path
  tags = var.tags
}

resource "aws_iam_user" "iam_user" {
  count = length(var.equipo)
  name = "${var.equipo[count.index]}-${var.name}-${random_id.id.hex}"
  path = var.iam_path
  tags = var.tags
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_access_key.html

resource "aws_iam_access_key" "iam_access_key_master" {
  user = aws_iam_user.iam_user_master.name
}

resource "aws_iam_access_key" "iam_access_key" {
  count = length(var.equipo)
  user = aws_iam_user.iam_user[count.index].name
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_role.html

resource "aws_iam_role" "iam_role" {
  name = "role-${var.name}-${random_id.id.hex}"
  tags = var.tags

  # TODO: Get this policy from file
  # assume_role_policy = "${file("${var.assume_role_policy_file}")}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_policy.html

resource "aws_iam_policy" "iam_policy" {
  name        = "policy-${var.name}-${random_id.id.hex}"
  description = "Limited access policy"

  # TODO: Get this policy from file
  # policy = "${file("${var.iam_policy_file}")}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2LimitedAccess",
            "Effect": "Allow",
            "Action": [
                "ec2:RebootInstances",
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*::instance/*"
            ]
        },
        {
            "Sid": "Route53LimitedAccess",
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/${aws_route53_zone.dns_zone.zone_id}"
            ]
        },
        {
            "Sid": "SESLimitedAccess",
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendTemplatedEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html

resource "aws_iam_role_policy_attachment" "role_policy_attachment_inline" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_extra" {
  count = length(var.extra_iam_policies)
  role       = aws_iam_role.iam_role.name
  policy_arn = var.extra_iam_policies[count.index]
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/security_group.html

resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Allow all traffic"
  vpc_id      = var.vpc_id

  # TODO: Merge var.tags with Name tag
  # tags = {
  #   Name = "allow_all_traffic"
  # }
  # tags = var.tags
  tags        = merge(
                  var.tags,
                  {"Name" = "allow_all_traffic"}
                )
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html

resource "aws_security_group_rule" "allow_all_ingress_icmp" {
  type              = "ingress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_ingress_tcp" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_ingress_udp" {
  type              = "ingress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_egress_icmp" {
  type              = "egress"
  protocol          = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_egress_tcp" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

resource "aws_security_group_rule" "allow_all_egress_udp" {
  type              = "egress"
  protocol          = "udp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_all.id
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/instance.html

resource "aws_instance" "ec2_instance" {
  count = length(var.equipo)

  ami           = var.ami_id
  instance_type = var.instance_type
  # key_name      = var.key_name
  key_name      = aws_key_pair.ssh_key.key_name
  ebs_optimized = "true"
  monitoring    = "false"
  subnet_id = var.subnet_id

  disable_api_termination = "true"
  vpc_security_group_ids  = [ aws_security_group.allow_all.id ]

  # associate_public_ip_address = ? # check conflicts with EIP
  user_data   = ""            # bootstrap from file
  tags        = merge(
                  var.tags,
                  {"Name" = var.equipo[count.index]}
                )
  volume_tags = merge(
                  var.tags,
                  {"Name" = var.equipo[count.index]}
                )
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip.html

resource "aws_eip" "elastic_ip" {
  count = length(var.equipo)

  instance = aws_instance.ec2_instance[count.index].id # lookup instance with index
  vpc      = true
  # tags     = var.tags
  tags        = merge(
                  var.tags,
                  {"Name" = var.equipo[count.index]}
                )
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/eip_association.html

resource "aws_eip_association" "elastic_ip_association" {
  count = length(var.equipo)

  instance_id   = aws_instance.ec2_instance[count.index].id # lookup with index
  allocation_id = aws_eip.elastic_ip[count.index].id  # lookup with index
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/route53_zone.html

resource "aws_route53_zone" "dns_zone" {
  name = var.dns_domain
  tags = var.tags
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/route53_record.html

resource "aws_route53_record" "public_record_a" {
  count = length(var.equipo)

  zone_id = aws_route53_zone.dns_zone.zone_id
  # zone_id = var.dns_zone_id
  name    = "${var.equipo[count.index]}.${var.dns_domain}"
  type    = "A"
  ttl     = "300"
  records = [ aws_eip.elastic_ip[count.index].public_ip ]
}

resource "aws_route53_record" "private_record_a" {
  count = length(var.equipo)

  zone_id = aws_route53_zone.dns_zone.zone_id
  # zone_id = var.dns_zone_id
  name    = "${var.equipo[count.index]}.priv.${var.dns_domain}"
  type    = "A"
  ttl     = "300"
  records = [ aws_eip.elastic_ip[count.index].private_ip ]
}

resource "aws_route53_record" "mx" {
  # Create this record if we have a mail team
  count = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  # zone_id = var.dns_zone_id
  name    = var.dns_domain
  type    = "MX"
  ttl     = "300"
  # records = ["1 ${aws_route53_record.mail.name}"] # lookup by name
  records = ["1 ${aws_route53_record.public_record_a[index(var.equipo, "mail")].name}"]
}

resource "aws_route53_record" "spf" {
  # Create this record if we have a mail team
  count = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  # zone_id = var.dns_zone_id
  name    = var.dns_domain
  type    = "SPF"
  ttl     = "300"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
}

resource "aws_route53_record" "smtp" {
  # Create this record if we have a mail team
  count = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  # zone_id = var.dns_zone_id
  name    = "smtp.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  # records = [ aws_route53_record.mail.name ] # lookup by name
  records = [aws_route53_record.public_record_a[index(var.equipo, "mail")].name]
}

resource "aws_route53_record" "imap" {
  # Create this record if we have a mail team
  count = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  # zone_id = var.dns_zone_id
  name    = "imap.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_record.public_record_a[index(var.equipo, "mail")].name]
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
#   records = [ aws_ses_domain_identity.example.verification_token ]
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
#   zone_id = aws_route53_zone.example.zone_id
#   name    = "_amazonses.${aws_ses_domain_identity.example.id}"
#   type    = "TXT"
#   ttl     = "600"
#   records = [ aws_ses_domain_identity.example.verification_token ]
# }
#
# resource "aws_ses_domain_identity_verification" "example_verification" {
#   domain = aws_ses_domain_identity.example.id"
#
#   depends_on = [aws_route53_record.example_amazonses_verification_record]
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
#   domain = aws_ses_domain_identity.example.domain
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
#   domain           = aws_ses_domain_identity.example.domain
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
#   zone_id = aws_route53_zone.example.id
#   name    = aws_ses_domain_mail_from.example.mail_from_domain
#   type    = "MX"
#   ttl     = "600"
#   records = ["10 feedback-smtp.us-east-1.amazonses.com"] # Change to the region in which `aws_ses_domain_identity.example` is created
# }
#
# # Example Route53 TXT record for SPF
# resource "aws_route53_record" "example_ses_domain_mail_from_txt" {
#   zone_id = aws_route53_zone.example.id
#   name    = aws_ses_domain_mail_from.example.mail_from_domain
#   type    = "TXT"
#   ttl     = "600"
#   records = ["v=spf1 include:amazonses.com -all"]
# }

################################################################################
# https://www.terraform.io/docs/configuration-0-11/outputs.html

# output "web-instance" {
#   value = "${aws_instance.web.id}"
# }

output "iam_user" {
  value = [
    aws_iam_user.iam_user_master.name,
    aws_iam_user.iam_user.*.name,
  ]
}

output "route53_ns" {
  value = aws_route53_zone.dns_zone.name_servers
}

output "ec2_instances" {
  value = aws_instance.ec2_instance.*.id
}

output "elastic_ip" {
  value = [
    aws_eip.elastic_ip.*.public_ip,
    aws_eip.elastic_ip.*.private_ip,
  ]
}

output "dns_records_a" {
  value = [
    aws_route53_record.public_record_a.*.name,
    aws_route53_record.private_record_a.*.name,
  ]
}
