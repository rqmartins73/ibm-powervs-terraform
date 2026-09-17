variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Set via TF_VAR_ibmcloud_api_key or an environment variable read by IBM Cloud Schematics; never put a real key in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region for the ibm provider (e.g. eu-de)."
  type        = string
  default     = "eu-de"
}

variable "zone" {
  description = "PowerVS zone to create the example workspace in (e.g. eu-de-1)."
  type        = string
  default     = "eu-de-1"
}

variable "resource_group_id" {
  description = "32-character hex ID of the resource group to create the workspace in. Replace the placeholder before applying."
  type        = string
}

variable "workspace_name" {
  description = "Name for the example workspace."
  type        = string
  default     = "example-powervs-workspace"
}

variable "ssh_public_key" {
  description = "Public SSH key (OpenSSH format) to register in the workspace. Replace the placeholder before applying."
  type        = string
}
