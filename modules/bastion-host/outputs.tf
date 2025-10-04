output "bastion_host_public_ip" {
  value = length(module.bastion_host) > 0 ? module.bastion_host[0].public_ip : null
}