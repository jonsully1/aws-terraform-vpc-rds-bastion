variable "bastion__host_ami" {
  description = "The AMI ID for the bastion host"
  type        = string
  default     = "ami-00b60d039dbf51b19"
}

variable "bastion_host_instance_type" {
  description = "The instance type to use for the bastion host"
  type        = string
  default     = "t4g.micro"
}

variable "bastion_host_private_key_name" {
  type = string
}

variable "infra_name" {
  type = string
}

variable "env" {
  type = string
}

variable "iac" {
  type = string
}

variable "public_subnets" {
  description = "List of public subnets for the bastion host"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "Security group ID for the bastion host"
  type        = string
}

variable "bastion_enabled" {
  description = "Whether to create the bastion host"
  type        = bool
  default     = true
}

