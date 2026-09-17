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
  description = "GUID of an existing PowerVS workspace to deploy the LPAR into (e.g. the workspace_guid output of the powervs-workspace example). Replace the placeholder before applying."
  type        = string
}

variable "network_id" {
  description = "ID of an existing subnet (network) in that workspace to attach the LPAR to (e.g. one of the powervs-workspace example's subnet_ids values). Replace the placeholder before applying."
  type        = string
}

variable "image_name" {
  description = "Name of a stock or catalog image already available in the workspace, used to look up its image_id (e.g. an IBM i, AIX or Linux stock image name)."
  type        = string
  default     = "IBMi-75-04"
}

variable "lpar_name" {
  description = "Name for the example LPAR."
  type        = string
  default     = "example-lpar"
}

variable "key_pair_name" {
  description = "Name of an SSH key already registered in the workspace (e.g. the ssh_key_name used with the powervs-workspace example)."
  type        = string
}
