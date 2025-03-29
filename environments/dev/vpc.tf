module "vpc" {
  source = "../../modules/terraform-aws-vpc"

  name = "${var.infra_name}-${var.env}-vpc"
  cidr = var.vpc_cidr

  azs              = var.eu_west_2_availability_zones
  public_subnets   = [for k, v in var.eu_west_2_availability_zones : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in var.eu_west_2_availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in var.eu_west_2_availability_zones : cidrsubnet(var.vpc_cidr, 8, k + 6)]

  create_database_subnet_group = true
  enable_nat_gateway           = false

  tags = {
    Name        = "${var.infra_name}-${var.env}-vpc"
    Environment = var.env
    Terraform   = var.terraform
  }
}

module "security_group" {
  source  = "../../modules/terraform-aws-security-group"

  name        = "${var.infra_name}-${var.env}-rds-security-group"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-rds-security-group"
    Environment = var.env
    Terraform   = var.terraform
  }
}
