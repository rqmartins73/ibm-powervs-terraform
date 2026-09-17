output "subnet_ids" {
  description = "Map of subnet name to network ID."
  value       = { for k, v in ibm_pi_network.subnet : k => v.network_id }
}

output "subnet_cidrs" {
  description = "Map of subnet name to CIDR (null for pub-vlan subnets)."
  value       = { for k, v in local.subnets_by_name : k => (v.type == "vlan" ? v.cidr : null) }
}

output "subnet_crns" {
  description = "Map of subnet name to CRN."
  value       = { for k, v in ibm_pi_network.subnet : k => v.crn }
}

output "subnet_vlan_ids" {
  description = "Map of subnet name to the underlying VLAN ID."
  value       = { for k, v in ibm_pi_network.subnet : k => v.vlan_id }
}

output "network_attachment_ids" {
  description = "Map of \"network_id/pvm_instance_id\" to the network interface ID created to attach that network to that LPAR."
  value       = { for k, v in ibm_pi_network_interface.attachment : k => v.network_interface_id }
}

output "network_attachment_ip_addresses" {
  description = "Map of \"network_id/pvm_instance_id\" to the IP address assigned on that attachment."
  value       = { for k, v in ibm_pi_network_interface.attachment : k => v.ip_address }
}
