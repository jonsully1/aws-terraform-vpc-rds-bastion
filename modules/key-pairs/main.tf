resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.bastion.private_key_pem
  filename = "${var.root_directory}/${var.bastion_host_private_key_name}.pem"
  file_permission = "0600"


  depends_on = [tls_private_key.bastion]
}

module "bastion_key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.3"

  key_name   = var.bastion_host_private_key_name
  public_key = tls_private_key.bastion.public_key_openssh

  tags = {
    Name        = "${var.infra_name}-${var.env}-${var.bastion_host_private_key_name}"
    Environment = var.env
    IaC         = var.iac
  }
}

