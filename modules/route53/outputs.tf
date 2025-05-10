output "zone_ids" {
  description = "Map of zone names to zone IDs"
  value       = module.zones.route53_zone_zone_id
}

output "name_servers" {
  description = "Map of zone names to name servers"
  value       = module.zones.route53_zone_name_servers
}