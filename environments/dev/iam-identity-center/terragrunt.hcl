include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

dependency "iam_policy" {
  config_path = "../iam-policy"

  # Use mock outputs when iam-policy has no state yet.
  # During run-all apply, iam-policy is applied first (dependency ordering),
  # then iam-identity-center reads its real outputs.
  mock_outputs = {
    policy_json = ""
    policy_arn  = "arn:aws:iam::123456789012:policy/mock"
  }
}

terraform {
  source = "../../../modules/iam-identity-center"
}

inputs = merge(
  local.env_vars.inputs,
  {
    # Enable only after IAM Identity Center is active in your AWS org
    enabled = local.env_vars.inputs.sso_enabled

    # Permission set configuration
    permission_set_name = "HiveDomainReadOnly"
    session_duration    = "PT8H"

    # Use the policy from the iam-policy module
    inline_policy_json = dependency.iam_policy.outputs.policy_json

    # Sensitive values pulled from env.dev.hcl (gitignored)
    account_assignments = local.env_vars.inputs.sso_account_assignments
    create_group        = local.env_vars.inputs.sso_create_group
    group_name          = local.env_vars.inputs.sso_group_name
    group_description   = local.env_vars.inputs.sso_group_description
  }
)
