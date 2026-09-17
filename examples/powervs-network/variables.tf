variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Set via TF_VAR_ibmcloud_api_key or an environment variable read by IBM Cloud Schematics; never put a real key in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region for the ibm provider (e.g. eu-de). Must match the region of the workspace referenced by pi_cloud_instance_id."
  type        = string
  default     = "eu-de"
}

variable "zone" {
  description = "PowerVS zone for the ibm provider (e.g. eu-de-1). Must match the zone of the workspace referenced by pi_cloud_instance_id."
  type        = string
  default     = "eu-de-1"
}

variable "pi_cloud_instance_id" {
  description = "GUID of an existing PowerVS workspace to create subnets in (e.g. the workspace_guid output of the powervs-workspace example). Replace the placeholder before applying."
  type        = string
}

variable "existing_lpar_instance_id" {
  description = "Instance ID of an existing LPAR to attach the public subnet to after creation (e.g. the instance_id output of the powervs-lpar example). Replace the placeholder before applying."
  type        = string
}
