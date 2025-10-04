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
    vpc_id                  = "vpc-12345678"
    public_subnets          = ["subnet-123456", "subnet-abcdef"]
    private_route_table_ids = ["rtb-123456"]
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

terraform {
  source = "../../../modules/nat-gateway"
}

inputs = merge(
  local.env_vars.inputs,
  {
    nat_enabled = true  # Set to true when needed
    vpc_id                  = dependency.vpc.outputs.vpc_id,
    public_subnets          = dependency.vpc.outputs.public_subnets,
    private_route_table_ids = dependency.vpc.outputs.private_route_table_ids
  }
)
