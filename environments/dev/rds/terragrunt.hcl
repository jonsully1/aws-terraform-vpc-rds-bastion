include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

dependencies {
  paths = ["../vpc", "../security-groups"]
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    database_subnet_group = "subnet-123456"
  }
}

dependency "rds_security_group" {
  config_path = "../security-groups"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs = {
    security_group_id = "sg-12345678"
  }
}

terraform {
  source = "../../../modules/rds"
}

inputs = merge(
  local.env_vars.inputs,
  {
    database_subnet_group = dependency.vpc.outputs.database_subnet_group,
    rds_security_group_id = dependency.rds_security_group.outputs.rds_security_group_id,
  }
)

