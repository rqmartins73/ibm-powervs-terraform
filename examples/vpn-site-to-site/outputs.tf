output "vpn_gateway_id" {
  value = module.vpn.vpn_gateway_id
}

output "vpn_gateway_public_ip_addresses" {
  value = module.vpn.vpn_gateway_public_ip_addresses
}

output "connection_statuses" {
  value = module.vpn.connection_statuses
}
