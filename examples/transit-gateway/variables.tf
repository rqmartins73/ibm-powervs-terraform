variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Set via TF_VAR_ibmcloud_api_key or an environment variable read by IBM Cloud Schematics; never put a real key in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region for the ibm provider. Transit Gateway itself has no regional endpoint, but the provider still needs a region for other calls."
  type        = string
  default     = "eu-de"
}

variable "resource_group_id" {
  description = "32-character hex ID of the resource group to create the gateway in. Replace the placeholder before applying."
  type        = string
}

variable "gateway_name" {
  description = "Name for the example transit gateway."
  type        = string
  default     = "example-transit-gateway"
}

variable "location" {
  description = "Location metadata for the gateway (e.g. eu-de)."
  type        = string
  default     = "eu-de"
}

variable "vpc_crn" {
  description = "CRN of an existing VPC to connect to the gateway. Replace the placeholder before applying."
  type        = string
}

variable "powervs_workspace_crn" {
  description = "CRN of an existing PowerVS workspace to connect to the gateway (e.g. the workspace_crn output of the powervs-workspace example). Replace the placeholder before applying."
  type        = string
}
