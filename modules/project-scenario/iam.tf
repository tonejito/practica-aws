################################################################################
# https://www.terraform.io/docs/providers/aws/r/key_pair.html
# $ mkdir -vp ~/.ssh/keys
# $ chmod 0700 ~/.ssh/keys
# $ ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/keys/aws-ciencias_rsa -C "andres.hernandez@ciencias.unam.mx"

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.key_name}-${random_id.id.hex}"
  tags       = var.tags
  public_key = file("${var.ssh_key_file}")
  # public_key = "ssh-rsa ... email@example.com"
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
  name  = "${var.name}-${random_id.id.hex}"
  group = aws_iam_group.iam_group.name
  users = aws_iam_user.iam_user.*.name
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_user.html

resource "aws_iam_user" "iam_user" {
  count = length(local.user_list)
  name  = "${local.user_list[count.index]}-${var.name}-${random_id.id.hex}"
  path  = var.iam_path
  tags  = var.tags
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_access_key.html

resource "aws_iam_access_key" "iam_access_key" {
  count = length(local.user_list)
  user  = aws_iam_user.iam_user[count.index].name
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_role.html

resource "aws_iam_role" "iam_role" {
  name               = "role-${var.name}-${random_id.id.hex}"
  tags               = var.tags
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
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2LimitedAccess",
            "Effect": "Deny",
            "Action": [
                "ec2:RebootInstances",
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:instance/*"
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

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment-inline" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment-extra" {
  count      = length(var.extra_iam_policies)
  role       = aws_iam_role.iam_role.name
  policy_arn = var.extra_iam_policies[count.index]
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/iam_group_policy_attachment.html

resource "aws_iam_group_policy_attachment" "iam_group_policy_attachment-inline" {
  group      = aws_iam_group.iam_group.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_group_policy_attachment" "iam_group_policy_attachment-extra" {
  count      = length(var.extra_iam_policies)
  group      = aws_iam_group.iam_group.name
  policy_arn = var.extra_iam_policies[count.index]
}
