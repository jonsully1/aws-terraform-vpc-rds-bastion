variable "infra_name" {
  type = string
}

variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_route_table_ids" {
  type = list(string)
}

variable "nat_enabled" {
  description = "Whether to create the NAT gateway"
  type        = bool
  default     = true
}