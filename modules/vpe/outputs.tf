output "gateway_ids" {
  description = "Map of endpoint gateway name to gateway ID."
  value       = { for k, v in ibm_is_virtual_endpoint_gateway.gateway : k => v.id }
}

output "gateway_crns" {
  description = "Map of endpoint gateway name to gateway CRN."
  value       = { for k, v in ibm_is_virtual_endpoint_gateway.gateway : k => v.crn }
}

output "gateway_health_states" {
  description = "Map of endpoint gateway name to health state (ok, degraded, faulted, inapplicable)."
  value       = { for k, v in ibm_is_virtual_endpoint_gateway.gateway : k => v.health_state }
}

output "reserved_ip_addresses" {
  description = "Map of \"gateway_name/subnet_id\" to the private IP address reserved for that gateway on that subnet."
  value       = { for k, v in ibm_is_subnet_reserved_ip.reserved_ip : k => v.address }
}
