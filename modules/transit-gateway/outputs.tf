output "transit_gateway_id" {
  description = "ID of the transit gateway."
  value       = ibm_tg_gateway.gateway.id
}

output "transit_gateway_crn" {
  description = "CRN of the transit gateway."
  value       = ibm_tg_gateway.gateway.crn
}

output "transit_gateway_status" {
  description = "Configuration status of the gateway itself (e.g. available, pending)."
  value       = ibm_tg_gateway.gateway.status
}

output "vpc_connection_ids" {
  description = "Map of VPC connection name to connection ID."
  value       = { for k, v in ibm_tg_connection.vpc : k => v.id }
}

output "vpc_connection_statuses" {
  description = "Map of VPC connection name to connection status (e.g. attached, failed, pending, deleting)."
  value       = { for k, v in ibm_tg_connection.vpc : k => v.status }
}

output "powervs_connection_ids" {
  description = "Map of PowerVS workspace connection name to connection ID."
  value       = { for k, v in ibm_tg_connection.powervs : k => v.id }
}

output "powervs_connection_statuses" {
  description = "Map of PowerVS workspace connection name to connection status (e.g. attached, failed, pending, deleting)."
  value       = { for k, v in ibm_tg_connection.powervs : k => v.status }
}
