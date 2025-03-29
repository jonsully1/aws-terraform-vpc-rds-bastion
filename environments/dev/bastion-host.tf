module "bastion_host" {
  source = "../../modules/terraform-aws-ec2-instance"

  name = "${var.infra_name}-${var.env}-bastion-host"

  ami                         = var.bastion__host_ami
  instance_type               = var.bastion_host_instance_type
  key_name                    = var.bastion_host_key_name
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.bastion_security_group.security_group_id]
  associate_public_ip_address = true

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 8
      throughput  = 125
    },
  ]

  tags = {
    Name        = "${var.infra_name}-${var.env}-bastion-host"
    Environment = var.env
    Terraform   = var.terraform
  }
}

output "bastion_host_public_ip" {
  value = module.bastion_host.public_ip
}
