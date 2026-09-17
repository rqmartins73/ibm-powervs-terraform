variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Set via TF_VAR_ibmcloud_api_key or an environment variable read by IBM Cloud Schematics; never put a real key in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region for the ibm provider (e.g. eu-es for Madrid). Must match the region of vpc_id and the subnets in subnet_id."
  type        = string
  default     = "eu-de"
}

variable "resource_group_id" {
  description = "32-character hex ID of the resource group to create the gateway in. Replace the placeholder before applying."
  type        = string
}

variable "vpc_id" {
  description = "ID of an existing VPC to create the endpoint gateway in. Replace the placeholder before applying."
  type        = string
}

variable "subnet_id" {
  description = "ID of an existing subnet in that VPC to reserve a private IP on for the gateway. Replace the placeholder before applying."
  type        = string
}

variable "cos_endpoint_crn" {
  description = "CRN of the regional Cloud Object Storage private endpoint to connect to. Replace the placeholder with the real CRN for your region (look it up per IBM Cloud docs; it is not the same in every region)."
  type        = string
}
