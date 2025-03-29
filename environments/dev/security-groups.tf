module "rds_security_group" {
  source = "../../modules/terraform-aws-security-group"

  name        = "${var.infra_name}-${var.env}-rds-security-group"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id

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

module "lambda_security_group" {
  source = "../../modules/terraform-aws-security-group"

  name        = "${var.infra_name}-${var.env}-lambda-security-group"
  description = "Security group for Lmmbda"
  vpc_id      = module.vpc.vpc_id

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
    Terraform   = var.terraform
  }
}

module "bastion_security_group" {
  source = "../../modules/terraform-aws-security-group"

  name        = "${var.infra_name}-${var.env}-bastion-security-group"
  description = "Security group for Bastion"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access from my IP"
      cidr_blocks = var.my_ip
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
    Terraform   = var.terraform
  }
}


