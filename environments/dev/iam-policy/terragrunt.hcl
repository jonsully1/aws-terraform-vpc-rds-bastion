include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

terraform {
  source = "../../../modules/iam-policy"
}

inputs = merge(
  local.env_vars.inputs,
  {
    # Override defaults if needed:
    # policy_name_suffix = "hive-domain-readonly"
    # route53_actions    = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    # acm_actions        = ["acm:ListCertificates", "acm:DescribeCertificate"]
  }
)
