output "role_arn" {
  description = "ARN of the IAM role that GitHub Actions assumes"
  value       = var.enabled ? aws_iam_role.github_actions[0].arn : ""
}

output "role_name" {
  description = "Name of the IAM role"
  value       = var.enabled ? aws_iam_role.github_actions[0].name : ""
}

output "role_id" {
  description = "Unique ID of the IAM role"
  value       = var.enabled ? aws_iam_role.github_actions[0].unique_id : ""
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC identity provider"
  value       = var.enabled ? aws_iam_openid_connect_provider.github_actions[0].arn : ""
}

output "oidc_provider_url" {
  description = "URL of the GitHub OIDC identity provider"
  value       = var.enabled ? aws_iam_openid_connect_provider.github_actions[0].url : ""
}

output "policy_arn" {
  description = "ARN of the Terraform state access policy (empty if tfstate_bucket_name not set)"
  value       = var.enabled && var.tfstate_bucket_name != "" ? aws_iam_policy.tfstate[0].arn : ""
}
