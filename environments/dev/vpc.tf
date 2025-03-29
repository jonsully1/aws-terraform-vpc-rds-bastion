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

module "fck-nat" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.3.0"

  name      = "${var.infra_name}-${var.env}-fck-nat"
  vpc_id    = module.vpc.vpc_id
  subnet_id = element(module.vpc.public_subnets, 0)
  # ha_mode              = true                 # Enables high-availability mode
  # eip_allocation_ids   = ["eipalloc-abc1234"] # Allocation ID of an existing EIP
  # use_cloudwatch_agent = true                 # Enables Cloudwatch agent and have metrics reported

  update_route_tables = true
  route_tables_ids = {
    "${module.vpc.private_route_table_ids[0]}" = module.vpc.private_route_table_ids[0]
  }
}
