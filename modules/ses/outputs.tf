output "ses_domain_identities" {
  description = "SES domain identity resources"
  value = {
    for idx, domain in var.domains :
    domain.domain_name => {
      arn                = aws_ses_domain_identity.domain_identity[idx].arn
      verification_token = aws_ses_domain_identity.domain_identity[idx].verification_token
    }
  }
}

output "ses_dkim_tokens" {
  description = "DKIM tokens for each domain (for DNS configuration)"
  value = {
    for idx, domain in var.domains :
    domain.domain_name => aws_ses_domain_dkim.domain_dkim[idx].dkim_tokens
  }
}

output "mail_from_domains" {
  description = "Custom MAIL FROM domains configured for each domain"
  value = var.enable_mail_from_domain ? {
    for idx, domain in var.domains :
    domain.domain_name => aws_ses_domain_mail_from.mail_from[idx].mail_from_domain
  } : {}
}

output "aws_region" {
  description = "AWS region where SES is configured"
  value       = data.aws_region.current.name
}

output "smtp_endpoint" {
  description = "SMTP endpoint for sending emails via SES"
  value       = "email-smtp.${data.aws_region.current.name}.amazonaws.com"
}

output "smtp_ports" {
  description = "Available SMTP ports"
  value = {
    tls = 587
    ssl = 465
  }
}

output "ses_sending_enabled" {
  description = "Whether SES sending is enabled for these domains"
  value       = true
}

output "next_steps" {
  description = "Instructions for completing SES setup"
  value = <<-EOT
    SES domain verification is in progress. Complete these steps:
    
    1. Wait for domain verification (DNS records have been created automatically)
    2. Create SMTP credentials in AWS Console:
       - Go to SES Console → SMTP settings → Create SMTP credentials
       - Save the username and password
    
    3. Use these SMTP settings in your application:
       - Server: email-smtp.${data.aws_region.current.name}.amazonaws.com
       - Port: 587 (TLS) or 465 (SSL)
       - Username: [from step 2]
       - Password: [from step 2]
    
    4. If your AWS account is in SES sandbox mode:
       - You can only send to verified email addresses
       - Request production access in SES Console → Account dashboard
    
    5. Test sending with AWS CLI:
       aws ses send-email --from noreply@${var.domains[0].domain_name} --to test@example.com --subject "Test" --text "Test message"
  EOT
}
