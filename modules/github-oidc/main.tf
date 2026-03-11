# -------------------------------------------------------------------
# GitHub Actions OIDC – OpenID Connect provider + IAM assumable role
# -------------------------------------------------------------------
#
# Creates an OIDC identity provider for GitHub Actions in your AWS
# account and an IAM role that GitHub Actions workflows can assume
# using short-lived tokens.  No long-lived access keys required.
#
# Based on:
#   https://jonsully1.dev/posts/deploying-aws-infrastructure-via-github-actions-with-open-id-connect
#   https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
# -------------------------------------------------------------------

locals {
  github_oidc_config = {
    provider_url = "https://token.actions.githubusercontent.com"
    audience     = "sts.amazonaws.com"
  }

  role_name = "${var.infra_name}-${var.env}-${var.role_name_suffix}"

  # Build the list of allowed OIDC subjects from all repos + their claims
  oidc_subjects = flatten([
    for repo in var.github_repos : [
      for claim in repo.claims :
      "repo:${repo.org}/${repo.repo}:${claim}"
    ]
  ])

  common_tags = merge(
    {
      Name        = local.role_name
      Environment = var.env
      IaC         = var.iac
    },
    var.tags,
  )
}

# ---------------------------
# OIDC Provider
# ---------------------------

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.enabled ? 1 : 0

  url             = local.github_oidc_config.provider_url
  client_id_list  = [local.github_oidc_config.audience]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]

  tags = local.common_tags
}

# ---------------------------
# Assume-role trust policy
# ---------------------------

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [local.github_oidc_config.audience]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.oidc_subjects
    }
  }
}

# ---------------------------
# IAM Role
# ---------------------------

resource "aws_iam_role" "github_actions" {
  count = var.enabled ? 1 : 0

  name                 = local.role_name
  assume_role_policy   = data.aws_iam_policy_document.assume_role[0].json
  max_session_duration = var.max_session_duration

  tags = local.common_tags
}

# ---------------------------
# IAM Policy – Terraform state access (S3 + DynamoDB)
# ---------------------------

data "aws_iam_policy_document" "tfstate" {
  count = var.enabled && var.tfstate_bucket_name != "" ? 1 : 0

  statement {
    sid    = "TerraformStateS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.tfstate_bucket_name}",
      "arn:aws:s3:::${var.tfstate_bucket_name}/*",
    ]
  }

  dynamic "statement" {
    for_each = var.tfstate_lock_table_name != "" ? [1] : []
    content {
      sid    = "TerraformStateDynamoDB"
      effect = "Allow"

      actions = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable",
      ]

      resources = [
        "arn:aws:dynamodb:*:*:table/${var.tfstate_lock_table_name}",
      ]
    }
  }

  dynamic "statement" {
    for_each = var.additional_policy_statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "tfstate" {
  count = var.enabled && var.tfstate_bucket_name != "" ? 1 : 0

  name        = "${local.role_name}-policy"
  description = "Grants GitHub Actions access to Terraform state (S3 + DynamoDB) and any additional statements"
  policy      = data.aws_iam_policy_document.tfstate[0].json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "tfstate" {
  count = var.enabled && var.tfstate_bucket_name != "" ? 1 : 0

  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.tfstate[0].arn
}

# ---------------------------
# Optional: attach AWS managed policies
# ---------------------------

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = var.enabled ? toset(var.managed_policy_arns) : toset([])

  role       = aws_iam_role.github_actions[0].name
  policy_arn = each.value
}
