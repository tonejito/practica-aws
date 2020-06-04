################################################################################
# https://www.terraform.io/docs/providers/aws/r/route53_zone.html

resource "aws_route53_zone" "dns_zone" {
  name = var.dns_domain
  tags = var.tags
}

################################################################################
# https://www.terraform.io/docs/providers/aws/r/route53_record.html
# TODO: Add AAAA public and private records when IPv6 support is ebs_enabled
# on aws_subnet and aws_instance

resource "aws_route53_record" "public_record_a" {
  count   = length(var.equipo)
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "${var.equipo[count.index]}.${var.dns_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.elastic_ip[count.index].public_ip]
}

resource "aws_route53_record" "private_record_a" {
  count   = length(var.equipo)
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "${var.equipo[count.index]}.priv.${var.dns_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.elastic_ip[count.index].private_ip]
}

# S3 static website
resource "aws_route53_record" "_" {
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = var.dns_domain
  type    = "A"

  alias {
    name    = aws_s3_bucket.s3_static_website.website_domain
    zone_id = aws_s3_bucket.s3_static_website.hosted_zone_id

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "mx" {
  # Create this record if we have a mail team
  count   = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = var.dns_domain
  type    = "MX"
  ttl     = "300"
  records = ["1 ${aws_route53_record.public_record_a[index(var.equipo, "mail")].name}"]
}

resource "aws_route53_record" "spf" {
  # Create this record if we have a mail team
  count   = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = var.dns_domain
  type    = "SPF"
  ttl     = "300"
  records = ["v=spf1 mx a include:amazonses.com ~all"]
}

resource "aws_route53_record" "smtp" {
  # Create this record if we have a mail team
  count   = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "smtp.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_record.public_record_a[index(var.equipo, "mail")].name]
}

resource "aws_route53_record" "imap" {
  # Create this record if we have a mail team
  count   = contains(var.equipo, "mail") == true ? 1 : 0
  zone_id = aws_route53_zone.dns_zone.zone_id
  name    = "imap.${var.dns_domain}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_route53_record.public_record_a[index(var.equipo, "mail")].name]
}
