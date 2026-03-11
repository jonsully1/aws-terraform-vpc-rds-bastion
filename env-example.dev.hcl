inputs = {
  infra_name                    = "your-infra-name"
  aws_region                    = "your-region"
  env                           = "dev"
  iac                           = "terragrunt"
  my_ips                         = ["your-ip/32", "another-ip/32"]
  bastion_host_private_key_name = "your-key-name"

  # -----------------------------------------------------------------
  # IAM Identity Center (SSO) Configuration
  # -----------------------------------------------------------------
  # Set to true only after enabling IAM Identity Center in your AWS org
  sso_enabled    = false

  # Your AWS account ID (used for SSO account assignments)
  sso_account_id = "your-aws-account-id"

  # Which groups/users should receive the SSO permission set
  sso_account_assignments = [
    {
      account_id     = "your-aws-account-id"
      principal_type = "GROUP"              # GROUP or USER
      principal_name = \"YourAppName\"         # e.g. \"HiveBackend\" — display name in Identity Store
    },
  ]

  # Set to true to create the group in Identity Center via Terraform
  sso_create_group      = false
  sso_group_name        = "YourAppName"       # e.g. "HiveBackend"
  sso_group_description = "Application backend — read-only Route 53 and ACM access"
}