variable "route53_hosted_zones" {
  description = "List of Route53 hosted zones and their records"
  type = list(object({
    name    = string
    zone_id = optional(string)
    comment = optional(string)
    tags    = object({
      project = string
    })
    records = optional(list(object({
      name    = string
      type    = string
      ttl     = number
      records = list(string)
      tags    = object({
        project = string
      })
    })))
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
