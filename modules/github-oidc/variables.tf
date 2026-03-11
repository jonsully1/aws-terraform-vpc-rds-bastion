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
  description = "Set to true to provision the GitHub OIDC provider and assumable role"
  type        = bool
  default     = false
}

variable "github_repos" {
  description = <<-EOT
    List of GitHub repositories allowed to assume the role.
    Each entry specifies an org, repo, and which branches/events are permitted.

    Example:
      github_repos = [
        {
          org    = "my-org"
          repo   = "infra-repo"
          claims = ["ref:refs/heads/main"]
        },
        {
          org    = "my-org"
          repo   = "app-repo"
          claims = ["*"]
        },
      ]

    claims examples:
      - "ref:refs/heads/main"  — only the main branch
      - "*"                    — any branch or event
  EOT
  type = list(object({
    org    = string
    repo   = string
    claims = list(string)
  }))
  default = []
}

variable "role_name_suffix" {
  description = "Suffix appended to the IAM role name"
  type        = string
  default     = "github-actions"
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the IAM role (default: 1 hour)"
  type        = number
  default     = 3600
}

variable "tfstate_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state (for granting state access)"
  type        = string
  default     = ""
}

variable "tfstate_lock_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  type        = string
  default     = ""
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements to attach to the role"
  type = list(object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "managed_policy_arns" {
  description = "List of existing IAM managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
