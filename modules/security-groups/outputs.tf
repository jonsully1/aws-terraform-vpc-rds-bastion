output "lambda_security_group_id" {
  value = module.lambda_security_group.security_group_id
}

output "rds_security_group_id" {
  value = module.rds_security_group.security_group_id
}

output "bastion_security_group_id" {
  value = module.bastion_security_group.security_group_id
}

