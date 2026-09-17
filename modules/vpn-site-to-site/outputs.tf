output "vpn_gateway_id" {
  description = "ID of the VPN gateway."
  value       = ibm_is_vpn_gateway.gateway.id
}

output "vpn_gateway_crn" {
  description = "CRN of the VPN gateway."
  value       = ibm_is_vpn_gateway.gateway.crn
}

output "vpn_gateway_public_ip_addresses" {
  description = "Public IP addresses assigned to the VPN gateway's members."
  value       = compact([ibm_is_vpn_gateway.gateway.public_ip_address, ibm_is_vpn_gateway.gateway.public_ip_address2])
}

output "ike_policy_id" {
  description = "ID of the shared IKE policy, or null if ike_policy was not provided."
  value       = try(ibm_is_ike_policy.ike[0].id, null)
}

output "ipsec_policy_id" {
  description = "ID of the shared IPsec policy, or null if ipsec_policy was not provided."
  value       = try(ibm_is_ipsec_policy.ipsec[0].id, null)
}

output "connection_ids" {
  description = "Map of connection name to connection ID."
  value       = { for k, v in ibm_is_vpn_gateway_connection.connection : k => v.gateway_connection }
}

output "connection_statuses" {
  description = "Map of connection name to connection status (up or down)."
  value       = { for k, v in ibm_is_vpn_gateway_connection.connection : k => v.status }
}
