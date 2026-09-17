output "workspace_id" {
  description = "Resource instance ID of the PowerVS workspace."
  value       = ibm_resource_instance.workspace.id
}

output "workspace_guid" {
  description = "GUID of the PowerVS workspace. This is the value the powervs-lpar module and pi_* resources use as pi_cloud_instance_id."
  value       = ibm_resource_instance.workspace.guid
}

output "workspace_crn" {
  description = "CRN of the PowerVS workspace."
  value       = ibm_resource_instance.workspace.crn
}

output "region" {
  description = "IBM Cloud region passed in var.region, echoed back for convenience."
  value       = var.region
}

output "zone" {
  description = "PowerVS zone the workspace was created in."
  value       = var.zone
}

output "subnet_ids" {
  description = "Map of subnet name to subnet (network) ID."
  value       = { for k, v in ibm_pi_network.subnet : k => v.network_id }
}

output "subnet_cidrs" {
  description = "Map of subnet name to CIDR (null for pub-vlan subnets)."
  value       = { for k, v in local.subnets_by_name : k => (v.type == "vlan" ? v.cidr : null) }
}

output "ssh_key_id" {
  description = "ID of the workspace SSH key, or null if ssh_key_public_key was not provided."
  value       = try(ibm_pi_key.workspace_key[0].id, null)
}
