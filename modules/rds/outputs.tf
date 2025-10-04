output "rds_mysql_db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "rds_postgres_db_instance_endpoint" {
  value = module.rds-postgres.db_instance_endpoint
}
