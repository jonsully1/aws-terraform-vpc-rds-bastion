variable "infra_name" {
  description = "Infrastructure name prefix"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "iac" {
  description = "IaC tool identifier for tagging"
  type        = string
}

variable "policy_name_suffix" {
  description = "Suffix appended to the IAM policy name (e.g. 'hive-domain-readonly')"
  type        = string
  default     = "hive-domain-readonly"
}

variable "policy_description" {
  description = "Description for the IAM policy"
  type        = string
  default     = "Read-only access to Route 53 hosted zones/records and ACM certificates"
}

variable "route53_actions" {
  description = "List of Route 53 actions to allow"
  type        = list(string)
  default = [
    "route53:ListHostedZones",
    "route53:ListResourceRecordSets",
  ]
}

variable "acm_actions" {
  description = "List of ACM actions to allow"
  type        = list(string)
  default = [
    "acm:ListCertificates",
    "acm:DescribeCertificate",
  ]
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements to include"
  type = list(object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
