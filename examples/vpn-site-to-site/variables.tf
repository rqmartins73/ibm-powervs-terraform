variable "ibmcloud_api_key" {
  description = "IBM Cloud API key. Set via TF_VAR_ibmcloud_api_key or an environment variable read by IBM Cloud Schematics; never put a real key in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "IBM Cloud region for the ibm provider (e.g. eu-es for Madrid). Must match the region that owns vpc_subnet_id."
  type        = string
  default     = "eu-de"
}

variable "resource_group_id" {
  description = "32-character hex ID of the resource group to create the gateway and policies in. Replace the placeholder before applying."
  type        = string
}

variable "vpc_subnet_id" {
  description = "ID of an existing VPC subnet to host the VPN gateway. Replace the placeholder before applying."
  type        = string
}

variable "gateway_name" {
  description = "Name for the example VPN gateway."
  type        = string
  default     = "example-vpn-gateway"
}

variable "vpc_cidr" {
  description = "CIDR of the VPC side of the tunnel (local_cidrs)."
  type        = string
  default     = "10.60.0.0/16"
}

variable "peer_gateway_address" {
  description = "IP address of the on-premises (peer) VPN gateway. Replace the placeholder before applying."
  type        = string
}

variable "peer_cidr" {
  description = "CIDR of the on-premises (peer) network reachable through the tunnel."
  type        = string
  default     = "192.168.0.0/16"
}

variable "preshared_key" {
  description = "Preshared key for the connection. Replace the placeholder with your own secret; never commit a real one to terraform.tfvars."
  type        = string
  sensitive   = true
}
