output "transit_gateway_id" {
  value = module.transit_gateway.transit_gateway_id
}

output "vpc_connection_statuses" {
  value = module.transit_gateway.vpc_connection_statuses
}

output "powervs_connection_statuses" {
  value = module.transit_gateway.powervs_connection_statuses
}
