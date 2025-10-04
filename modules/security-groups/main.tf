module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${var.infra_name}-${var.env}-rds-security-group"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MySQL access from bastion"
      source_security_group_id = module.bastion_security_group.security_group_id
    },
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MySQL access from Lambda"
      source_security_group_id = module.lambda_security_group.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from bastion"
      source_security_group_id = module.bastion_security_group.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from Lambda"
      source_security_group_id = module.lambda_security_group.security_group_id
    }
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-rds-security-group"
    Environment = var.env
    IaC         = var.iac
  }
}

module "lambda_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${var.infra_name}-${var.env}-lambda-security-group"
  description = "Security group for Lmmbda"
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "All outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-lambda-security-group"
    Environment = var.env
    IaC         = var.iac
  }
}

module "bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${var.infra_name}-${var.env}-bastion-security-group"
  description = "Security group for Bastion"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from my home IP"
      cidr_blocks = var.my_ips[0]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from my parents IP"
      cidr_blocks = var.my_ips[1]
    }, 
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from my parents IP"
      cidr_blocks = var.my_ips[2]
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-bastion-security-group"
    Environment = var.env
    IaC         = var.iac
  }
}

module "rds_postgres_db_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name        = "${var.infra_name}-${var.env}-rds-postgre-db-security-group"
  description = "Security group for RDS Postgre DB"
  vpc_id      = var.vpc_id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from bastion"
      source_security_group_id = module.bastion_security_group.security_group_id
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from Lambda"
      source_security_group_id = module.lambda_security_group.security_group_id
    }
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-rds-postgre-db-security-group"
    Environment = var.env
    IaC         = var.iac
  }
}
