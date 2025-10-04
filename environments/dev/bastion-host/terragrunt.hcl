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

  mock_outputs = {
    public_subnets = ["subnet-123456", "subnet-abcdef"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "bastion_security_group" {
  config_path = "../security-groups"

  mock_outputs = {
    security_group_id = "sg-12345678"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/bastion-host"
}

inputs = merge(
  local.env_vars.inputs,
  {
    bastion_enabled           = true,  # Set to true to enable the bastion host
    public_subnets            = dependency.vpc.outputs.public_subnets,
    bastion_security_group_id = dependency.bastion_security_group.outputs.bastion_security_group_id,
  }
)


