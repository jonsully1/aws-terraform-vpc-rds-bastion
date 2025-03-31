variable "eu_west_2_availability_zones" {
  description = "List of availability zones for the region"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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
