module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.11.0"

  identifier           = "${var.infra_name}-${var.env}-rds-instance"
  engine               = "mysql"
  engine_version       = "8.0"
  family               = "mysql8.0"
  major_engine_version = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"

  allocated_storage     = 20
  max_allocated_storage = 20

  multi_az               = false
  db_subnet_group_name   = var.database_subnet_group
  vpc_security_group_ids = [var.rds_security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 7

  enabled_cloudwatch_logs_exports = ["general"]
  create_cloudwatch_log_group     = true

  publicly_accessible = false
  # deletion_protection = true
  skip_final_snapshot = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-rds-instance"
    Environment = var.env
    IaC         = var.iac
  }
}
