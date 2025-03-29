variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "infra_name" {
  description = "The infrastructure name"
  type        = string
}

variable "terraform" {
  description = "Provisioned by Terraform"
  type        = bool
  default     = true
}

variable "env" {
  description = "The infrastructure environment"
  type        = string
}

variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default = "jonsully1"
}

variable "db_username" {
  description = "The username for the database"
  type        = string
}

variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Your IP address to allow ingress"
  type        = string
}

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
