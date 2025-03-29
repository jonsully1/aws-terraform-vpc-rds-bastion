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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}
