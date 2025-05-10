module "zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 3.0"

  zones = {
    for zone in var.route53_hosted_zones : zone.name => {
      comment = zone.comment
      tags    = zone.tags
    }
  }

    tags = {
    Name        = "${var.infra_name}-${var.env}-route53-hosted-zones"
    Environment = var.env
    IaC         = var.iac
  }
}
