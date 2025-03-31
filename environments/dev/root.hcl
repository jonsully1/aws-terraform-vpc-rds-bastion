
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

# Configure the remote backend
remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = "johno-terragrunt-mar-2025"

    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "johno-terragrunt-mar-2025-lock-table"
  }
}

# Configure the AWS provider
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "eu-west-2"
}
EOF
}

# Configure the module
#
# The URL used here is a shorthand for
# "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.16.0".
#
# You can find the module at:
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
#
# Note the extra `/` after the `tfr` protocol is required for the shorthand
# notation.
terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=5.16.0"
}

inputs = merge(
  local.env_vars.inputs,
)