include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

dependencies {
  paths = ["../vpc"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
}

terraform {
  source = "../../../modules/security-groups"
}

inputs = merge(
  local.env_vars.inputs,
  {
    vpc_id = dependency.vpc.outputs.vpc_id
  }
)

