output "permission_set_arn" {
  description = "ARN of the SSO permission set"
  value       = var.enabled ? aws_ssoadmin_permission_set.this[0].arn : ""
}

output "permission_set_name" {
  description = "Name of the SSO permission set"
  value       = var.enabled ? aws_ssoadmin_permission_set.this[0].name : ""
}

output "sso_instance_arn" {
  description = "ARN of the IAM Identity Center instance"
  value       = local.sso_instance_arn
}

output "identity_store_id" {
  description = "ID of the Identity Store"
  value       = local.identity_store_id
}

output "sso_start_url" {
  description = "The SSO start URL (portal URL) — use this in ~/.aws/config"
  value       = var.enabled ? "https://${tolist(data.aws_ssoadmin_instances.this[0].identity_store_ids)[0]}.awsapps.com/start" : ""
}

output "group_id" {
  description = "ID of the created Identity Store group (empty if create_group = false)"
  value       = var.enabled && var.create_group ? aws_identitystore_group.this[0].group_id : ""
}

output "account_assignment_ids" {
  description = "Map of account assignment keys to their IDs"
  value = {
    for k, v in aws_ssoadmin_account_assignment.this : k => v.id
  }
}
