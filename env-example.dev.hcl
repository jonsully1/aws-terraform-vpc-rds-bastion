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

  # -----------------------------------------------------------------
  # GitHub Actions OIDC Configuration
  # -----------------------------------------------------------------
  # Set to true to provision the OIDC provider and IAM assumable role
  github_oidc_enabled = false

  # GitHub repositories allowed to assume this role
  # Each entry specifies the org, repo, and which branches/events are permitted
  github_repos = [
    {
      org    = "your-github-org"
      repo   = "your-infra-repo"
      claims = ["ref:refs/heads/main"]   # main branch only
    },
    # Add more repos as needed:
    # {
    #   org    = "your-github-org"
    #   repo   = "your-app-repo"
    #   claims = ["*"]                   # any branch
    # },
  ]

  # Terraform state backend names (so the role can read/write state)
  github_oidc_tfstate_bucket_name    = "your-tfstate-bucket-name"
  github_oidc_tfstate_lock_table_name = "your-tfstate-lock-table-name"
}