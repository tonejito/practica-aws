################################################################################
# https://www.terraform.io/docs/providers/aws/r/ses_domain_identity.html

resource "aws_ses_domain_identity" "ses_domain_identity" {
  domain = var.dns_domain
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/ses_domain_identity_verification.html

resource "aws_route53_record" "ses_verification_record" {
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.ses_domain_identity.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.ses_domain_identity.verification_token]
}

resource "aws_ses_domain_identity_verification" "ses_domain_identity_verification" {
  depends_on = [aws_route53_record.ses_verification_record]
  domain     = aws_ses_domain_identity.ses_domain_identity.id
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/ses_domain_dkim.html
# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-authentication-dkim-easy-setup-domain.html

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = aws_ses_domain_identity.ses_domain_identity.domain
}

resource "aws_route53_record" "ses_dkim_verification_record" {
  count   = 3 # SES returns 3 DKIM CNAMES for verification
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/ses_domain_mail_from.html

resource "aws_ses_domain_mail_from" "ses_domain_mail_from" {
  domain           = aws_ses_domain_identity.ses_domain_identity.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.ses_domain_identity.domain}"
}

resource "aws_route53_record" "ses_domain_mail_from_mx" {
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = aws_ses_domain_mail_from.ses_domain_mail_from.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.aws_region}.amazonses.com"]
}

resource "aws_route53_record" "ses_domain_mail_from_txt" {
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = aws_ses_domain_mail_from.ses_domain_mail_from.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

################################################################################
# https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses-procedure.html
# https://docs.aws.amazon.com/cli/latest/reference/ses/verify-email-identity.html
#
# aws ses verify-email-identity --email-address sender@example.com
