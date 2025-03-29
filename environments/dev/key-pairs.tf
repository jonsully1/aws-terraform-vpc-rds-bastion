resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.bastion.private_key_pem
  filename        = "${path.module}/${var.bastion_host_key_name}.pem"
  file_permission = "0600"
}

module "bastion_key_pair" {
  source = "../../modules/terraform-aws-key-pair"

  key_name   = var.bastion_host_key_name
  public_key = tls_private_key.bastion.public_key_openssh

  tags = {
    Name        = "${var.infra_name}-${var.env}-${var.bastion_host_key_name}"
    Environment = var.env
    Terraform   = var.terraform
  }
}
