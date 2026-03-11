output "policy_arn" {
  description = "ARN of the IAM policy"
  value       = aws_iam_policy.this.arn
}

output "policy_name" {
  description = "Name of the IAM policy"
  value       = aws_iam_policy.this.name
}

output "policy_id" {
  description = "ID of the IAM policy"
  value       = aws_iam_policy.this.id
}

output "policy_json" {
  description = "The rendered JSON policy document"
  value       = data.aws_iam_policy_document.this.json
}
