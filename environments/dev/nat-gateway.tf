module "fck-nat" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.3.0"

  name      = "${var.infra_name}-${var.env}-fck-nat"
  vpc_id    = module.vpc.vpc_id
  subnet_id = element(module.vpc.public_subnets, 0)

  update_route_tables = true
  route_tables_ids = {
    "${module.vpc.private_route_table_ids[0]}" = module.vpc.private_route_table_ids[0]
  }
}
