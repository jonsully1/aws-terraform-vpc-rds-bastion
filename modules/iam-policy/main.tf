# -------------------------------------------------------------------
# IAM Policy – least-privilege read-only access to Route 53 and ACM
# -------------------------------------------------------------------
#
# Route 53 and ACM list/describe operations do not support
# resource-level ARN restrictions, so Resource: "*" is correct.
# The policy is still least-privilege — only read-only actions.
# -------------------------------------------------------------------

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "DomainAvailabilityReadOnly"
    effect = "Allow"

    actions = concat(
      var.route53_actions,
      var.acm_actions,
    )

    resources = ["*"]
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

resource "aws_iam_policy" "this" {
  name        = "${var.infra_name}-${var.env}-${var.policy_name_suffix}"
  description = var.policy_description
  policy      = data.aws_iam_policy_document.this.json

  tags = merge(
    {
      Name        = "${var.infra_name}-${var.env}-${var.policy_name_suffix}"
      Environment = var.env
      IaC         = var.iac
    },
    var.tags,
  )
}
