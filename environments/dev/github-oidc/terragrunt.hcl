include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

terraform {
  source = "../../../modules/github-oidc"
}

inputs = merge(
  local.env_vars.inputs,
  {
    # Enable only after you're ready to provision the OIDC provider
    enabled = local.env_vars.inputs.github_oidc_enabled

    # GitHub repositories allowed to assume this role
    github_repos = local.env_vars.inputs.github_repos

    # Terraform state backend — grants the role access to read/write state
    tfstate_bucket_name    = local.env_vars.inputs.github_oidc_tfstate_bucket_name
    tfstate_lock_table_name = local.env_vars.inputs.github_oidc_tfstate_lock_table_name

    # Additional managed policies (optional)
    # managed_policy_arns = []

    # Additional inline policy statements (optional)
    # additional_policy_statements = []
  }
)
