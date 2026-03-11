# -------------------------------------------------------------------
# IAM Identity Center (SSO) – permission set + account assignments
# -------------------------------------------------------------------
#
# This module:
#   1. Reads the existing IAM Identity Center instance (singleton per region).
#   2. Creates a permission set with an inline policy (Route 53 + ACM
#      read-only by default) and/or attached managed policies.
#   3. Optionally creates a group in the Identity Store.
#   4. Assigns the permission set to principals (groups/users) in
#      specified AWS accounts.
#
# After applying, the Hive application backend can assume this
# permission set to make read-only Route 53 and ACM API calls
# via short-lived SSO credentials.
#
# IMPORTANT: Set var.enabled = true only after IAM Identity Center
# has been enabled in your AWS organization. Otherwise the data
# source returns an empty list and the plan will fail.
# -------------------------------------------------------------------

# ---------------------------
# Data: SSO instance
# ---------------------------

data "aws_ssoadmin_instances" "this" {
  count = var.enabled ? 1 : 0
}

locals {
  sso_instance_arn  = var.enabled ? tolist(data.aws_ssoadmin_instances.this[0].arns)[0] : ""
  identity_store_id = var.enabled ? tolist(data.aws_ssoadmin_instances.this[0].identity_store_ids)[0] : ""

  # Default inline policy – Route 53 + ACM read-only
  default_inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DomainAvailabilityReadOnly"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
        ]
        Resource = "*"
      }
    ]
  })

  inline_policy = var.inline_policy_json != "" && var.inline_policy_json != "{}" ? var.inline_policy_json : local.default_inline_policy
}

# ---------------------------
# Permission set
# ---------------------------

resource "aws_ssoadmin_permission_set" "this" {
  count = var.enabled ? 1 : 0

  name             = var.permission_set_name
  description      = var.permission_set_description
  instance_arn     = local.sso_instance_arn
  session_duration = var.session_duration

  tags = merge(
    {
      Name        = "${var.infra_name}-${var.env}-${var.permission_set_name}"
      Environment = var.env
      IaC         = var.iac
    },
    var.tags,
  )
}

# Inline policy on the permission set
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  count = var.enabled ? 1 : 0

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[0].arn
  inline_policy      = local.inline_policy
}

# Optional: attach AWS managed policies
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = var.enabled ? toset(var.managed_policy_arns) : toset([])

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[0].arn
  managed_policy_arn = each.value
}

# ---------------------------
# Optional: Identity Store group
# ---------------------------

resource "aws_identitystore_group" "this" {
  count = var.enabled && var.create_group ? 1 : 0

  identity_store_id = local.identity_store_id
  display_name      = var.group_name
  description       = var.group_description
}

# ---------------------------
# Account assignments
# ---------------------------

# Look up each principal in the identity store so we can get its ID.
# Groups:
data "aws_identitystore_group" "assignments" {
  for_each = var.enabled ? {
    for a in var.account_assignments : "${a.account_id}-${a.principal_type}-${a.principal_name}" => a
    if a.principal_type == "GROUP" && !var.create_group
  } : {}

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = each.value.principal_name
    }
  }
}

# Users:
data "aws_identitystore_user" "assignments" {
  for_each = var.enabled ? {
    for a in var.account_assignments : "${a.account_id}-${a.principal_type}-${a.principal_name}" => a
    if a.principal_type == "USER"
  } : {}

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.principal_name
    }
  }
}

locals {
  # Build a map of assignment key → principal_id
  principal_ids = merge(
    {
      for k, v in data.aws_identitystore_group.assignments :
      k => v.group_id
    },
    {
      for k, v in data.aws_identitystore_user.assignments :
      k => v.user_id
    },
    # If we created the group ourselves, wire it in
    var.enabled && var.create_group ? {
      for a in var.account_assignments :
      "${a.account_id}-${a.principal_type}-${a.principal_name}" =>
      aws_identitystore_group.this[0].group_id
      if a.principal_type == "GROUP" && a.principal_name == var.group_name
    } : {},
  )
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.enabled ? {
    for a in var.account_assignments :
    "${a.account_id}-${a.principal_type}-${a.principal_name}" => a
  } : {}

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[0].arn

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

  principal_type = each.value.principal_type
  principal_id   = local.principal_ids[each.key]
}
