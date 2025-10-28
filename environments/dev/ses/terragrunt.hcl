include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ses"
}

dependency "route53" {
  config_path = "../route53"

  mock_outputs = {
    hosted_zones = {}
  }
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.dev.hcl"))
}

inputs = merge(
  local.env_vars.inputs,
  {
    # Pass the ses_domains from env.dev.hcl as the domains variable
    domains = local.env_vars.inputs.ses_domains
    
    # DMARC configuration (highly recommended for deliverability)
    enable_dmarc_record = true
    dmarc_policy        = "quarantine"  # Options: "none" (monitor), "quarantine" (spam folder), "reject" (block)
    dmarc_rua_email     = "dmarc-reports@londoncityweb.com"  # Where to receive DMARC reports (optional)
  }
)
