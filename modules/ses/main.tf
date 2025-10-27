data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# SES Domain Identity - Verify domain ownership for sending emails
resource "aws_ses_domain_identity" "domain_identity" {
  for_each = { for idx, domain in var.domains : idx => domain }

  domain = each.value.domain_name
}

# Route53 verification record for SES domain identity
resource "aws_route53_record" "amazonses_verification_record" {
  for_each = { for idx, domain in var.domains : idx => domain }

  zone_id = each.value.zone_id
  name    = "_amazonses.${each.value.domain_name}"
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.domain_identity[each.key].verification_token]
}

# DKIM records for email authentication (improves deliverability)
resource "aws_ses_domain_dkim" "domain_dkim" {
  for_each = { for idx, domain in var.domains : idx => domain }

  domain = aws_ses_domain_identity.domain_identity[each.key].domain
}

resource "aws_route53_record" "amazonses_dkim_record" {
  for_each = merge([
    for domain_idx, domain in var.domains : {
      for dkim_idx in range(3) :
      "${domain_idx}-${dkim_idx}" => {
        domain_idx = domain_idx
        dkim_idx   = dkim_idx
        zone_id    = domain.zone_id
      }
    }
  ]...)

  zone_id = each.value.zone_id
  name    = "${element(aws_ses_domain_dkim.domain_dkim[each.value.domain_idx].dkim_tokens, each.value.dkim_idx)}._domainkey"
  type    = "CNAME"
  ttl     = 600
  records = ["${element(aws_ses_domain_dkim.domain_dkim[each.value.domain_idx].dkim_tokens, each.value.dkim_idx)}.dkim.amazonses.com"]
}

# SPF record for email authentication (if not already set by Google Workspace)
# Note: If you already have an SPF record from Google Workspace, you'll need to merge them manually
resource "aws_route53_record" "amazonses_spf_record" {
  for_each = var.enable_spf_record ? { for idx, domain in var.domains : idx => domain } : {}

  zone_id = each.value.zone_id
  name    = each.value.domain_name
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com include:_spf.google.com ~all"]
}

# MAIL FROM domain (optional but recommended for better deliverability)
resource "aws_ses_domain_mail_from" "mail_from" {
  for_each = var.enable_mail_from_domain ? { for idx, domain in var.domains : idx => domain } : {}

  domain           = aws_ses_domain_identity.domain_identity[each.key].domain
  mail_from_domain = "mail.${each.value.domain_name}"
}

resource "aws_route53_record" "mail_from_mx" {
  for_each = var.enable_mail_from_domain ? { for idx, domain in var.domains : idx => domain } : {}

  zone_id = each.value.zone_id
  name    = aws_ses_domain_mail_from.mail_from[each.key].mail_from_domain
  type    = "MX"
  ttl     = 600
  records = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
}

resource "aws_route53_record" "mail_from_spf" {
  for_each = var.enable_mail_from_domain ? { for idx, domain in var.domains : idx => domain } : {}

  zone_id = each.value.zone_id
  name    = aws_ses_domain_mail_from.mail_from[each.key].mail_from_domain
  type    = "TXT"
  ttl     = 600
  records = ["v=spf1 include:amazonses.com ~all"]
}
