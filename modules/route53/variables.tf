variable "route53_hosted_zones" {
  description = "List of Route53 hosted zones and their records"
  type = list(object({
    name    = string
    comment = optional(string)
    tags    = object({
      project = string
    })
    records = optional(list(any))
  }))
  default = []
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
