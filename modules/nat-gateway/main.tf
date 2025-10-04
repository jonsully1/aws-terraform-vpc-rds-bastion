module "nat-gateway" {
  source  = "RaJiska/fck-nat/aws"
  version = "1.3.0"
  count   = var.nat_enabled ? 1 : 0

  name      = "${var.infra_name}-${var.env}-fck-nat-gateway"
  vpc_id    = var.vpc_id
  subnet_id = var.public_subnets[0]

  update_route_tables = true
  route_tables_ids = {
    "private-1" = var.private_route_table_ids[0]
    "private-2" = var.private_route_table_ids[1]
    "private-3" = var.private_route_table_ids[2]
  }
}