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

variable "enabled" {
  description = "Set to true to provision SSO resources. Requires IAM Identity Center to be enabled in your AWS organization first."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------
# Permission set
# ---------------------------------------------------------------

variable "permission_set_name" {
  description = "Name for the SSO permission set (e.g. 'HiveDomainReadOnly')"
  type        = string
  default     = "HiveDomainReadOnly"
}

variable "permission_set_description" {
  description = "Description for the permission set"
  type        = string
  default     = "Read-only access to Route 53 and ACM for domain availability checks"
}

variable "session_duration" {
  description = "Maximum session duration in ISO 8601 format (e.g. PT8H for 8 hours)"
  type        = string
  default     = "PT8H"
}

variable "inline_policy_json" {
  description = "JSON policy document to attach as an inline policy on the permission set. If empty, the module creates a default Route53+ACM read-only policy."
  type        = string
  default     = ""
}

variable "managed_policy_arns" {
  description = "List of AWS managed policy ARNs to attach to the permission set"
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------
# Account assignments
# ---------------------------------------------------------------

variable "account_assignments" {
  description = <<-EOT
    List of account assignments for this permission set. Each entry assigns
    the permission set to a principal (GROUP or USER) in a given AWS account.

    Example:
      account_assignments = [
        {
          account_id     = "123456789012"
          principal_type = "GROUP"           # GROUP or USER
          principal_name = "HiveBackend"     # Display name in Identity Store
        }
      ]
  EOT
  type = list(object({
    account_id     = string
    principal_type = string           # GROUP or USER
    principal_name = string           # display name looked up in identity store
  }))
  default = []
}

# ---------------------------------------------------------------
# Optional: create a group in IAM Identity Center
# ---------------------------------------------------------------

variable "create_group" {
  description = "Whether to create a new group in the IAM Identity Center identity store"
  type        = bool
  default     = false
}

variable "group_name" {
  description = "Display name of the group to create (only used when create_group = true)"
  type        = string
  default     = "HiveBackend"
}

variable "group_description" {
  description = "Description for the new group"
  type        = string
  default     = "Hive application backend — read-only Route 53 and ACM access"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
