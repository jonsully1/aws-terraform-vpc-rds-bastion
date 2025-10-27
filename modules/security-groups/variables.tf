variable "infra_name" {
  type = string
}

variable "env" {
  type = string
}

variable "my_ips" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = string
  }))
}

variable "iac" {
  type = string
}

variable "vpc_id" {
  type = string
}
