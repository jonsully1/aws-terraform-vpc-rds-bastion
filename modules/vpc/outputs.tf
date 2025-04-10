output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "database_subnet_group" {
  value = module.vpc.database_subnet_group
}
