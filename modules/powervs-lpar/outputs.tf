output "id" {
  description = "Terraform resource ID of the LPAR (composite of workspace GUID and instance ID)."
  value       = ibm_pi_instance.lpar.id
}

output "instance_id" {
  description = "Instance ID of the LPAR within the workspace."
  value       = ibm_pi_instance.lpar.instance_id
}

output "crn" {
  description = "CRN of the LPAR."
  value       = ibm_pi_instance.lpar.crn
}

output "status" {
  description = "Status of the LPAR as last observed by Terraform."
  value       = ibm_pi_instance.lpar.status
}

output "health_status" {
  description = "Health status of the LPAR as last observed by Terraform."
  value       = ibm_pi_instance.lpar.health_status
}

output "networks" {
  description = "Networks attached to the LPAR, including the assigned IP and MAC addresses."
  value       = ibm_pi_instance.lpar.pi_network
}

output "volume_ids" {
  description = "Map of data volume name to volume ID for the volumes this module created and attached."
  value       = { for k, v in ibm_pi_volume.data : k => v.volume_id }
}
