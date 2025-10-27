variable "infra_name" {
  description = "Infrastructure name prefix for resources"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "domains" {
  description = "List of domains with their Route53 zone IDs for SES email sending"
  type = list(object({
    domain_name = string
    zone_id     = string
  }))
}

variable "enable_spf_record" {
  description = "Whether to create SPF record. Set to false if you already have SPF from Google Workspace (you'll need to merge them manually)"
  type        = bool
  default     = false
}

variable "enable_mail_from_domain" {
  description = "Whether to configure a custom MAIL FROM domain (recommended for better deliverability)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
