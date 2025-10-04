inputs = {
  infra_name                    = "your-infra-name"
  aws_region                    = "your-region"
  env                           = "dev"
  iac                           = "terragrunt"
  my_ips                         = ["your-ip/32", "another-ip/32"]
  bastion_host_private_key_name = "your-key-name"
}