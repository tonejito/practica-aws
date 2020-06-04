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
