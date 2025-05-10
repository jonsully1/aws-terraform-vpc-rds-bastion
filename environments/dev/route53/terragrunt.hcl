include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

terraform {
  source = "../../../modules/route53"
}

inputs = merge(
  local.env_vars.inputs,
)