##############################################################################
# PowerVS Workspace Module - Variables
#
# The provider block (including ibmcloud_api_key, region and zone) is owned
# by the caller (root module / example), not by this module. This module
# only declares the ibm provider requirement in versions.tf.
##############################################################################

variable "name" {
  description = "Name of the PowerVS workspace (service instance). Must be 1-63 characters, lowercase letters, digits and hyphens only, and cannot start or end with a hyphen."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "name must be 1-63 characters, lowercase letters/digits/hyphens only, and cannot start or end with a hyphen."
  }
}

variable "region" {
  description = "IBM Cloud region the workspace belongs to (e.g. eu-de, us-south). Used for tagging/reference only; the actual location of the workspace is set by var.zone."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.region))
    error_message = "region must be lowercase alphanumeric segments separated by hyphens (e.g. eu-de, us-south)."
  }
}

variable "zone" {
  description = "PowerVS zone (datacenter) to create the workspace in (e.g. eu-de-1, dal12, lon04). This is the value passed as `location` to the underlying resource instance and must match the zone the caller's ibm provider is configured for when creating pi_* resources against this workspace."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.zone))
    error_message = "zone must be lowercase alphanumeric segments separated by hyphens (e.g. eu-de-1, dal12, lon04)."
  }
}

variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group the workspace is created in (32-character hex string, as returned by `ibmcloud resource groups`)."
  type        = string

  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "resource_group_id must be the 32-character hexadecimal resource group ID, not its name."
  }
}

variable "plan" {
  description = "Service plan for the PowerVS workspace service instance."
  type        = string
  default     = "power-virtual-server-group"

  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.plan))
    error_message = "plan must be lowercase alphanumeric segments separated by hyphens."
  }
}

variable "tags" {
  description = "Tags to apply to the workspace service instance."
  type        = list(string)
  default     = []
}

variable "ssh_key_name" {
  description = "Name for the SSH key registered in the workspace. Required when ssh_key_public_key is set."
  type        = string
  default     = null
}

variable "ssh_key_public_key" {
  description = "Public SSH key (e.g. contents of an id_rsa.pub / id_ed25519.pub file) to register in the workspace so LPARs created in it can use it. Leave null to skip creating a workspace-level SSH key."
  type        = string
  default     = null

  validation {
    condition     = var.ssh_key_public_key == null || can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ", var.ssh_key_public_key))
    error_message = "ssh_key_public_key must be a public key in OpenSSH format (starting with ssh-rsa, ssh-ed25519 or ecdsa-sha2-*)."
  }

  validation {
    condition     = var.ssh_key_public_key == null || (var.ssh_key_name != null && length(var.ssh_key_name) > 0)
    error_message = "ssh_key_name must be set when ssh_key_public_key is provided."
  }
}

variable "subnets" {
  description = <<-EOT
    Subnets to create in the workspace. At least one is required for the
    workspace to be usable by LPARs.

    - name: subnet name, unique within the list.
    - cidr: subnet CIDR in IPv4 notation (e.g. 10.51.0.0/24). Required when type is "vlan".
    - type: "vlan" (private) or "pub-vlan" (public). Defaults to "vlan".
    - dns:  optional list of DNS server IPs for the subnet.
  EOT
  type = list(object({
    name = string
    cidr = string
    type = optional(string, "vlan")
    dns  = optional(list(string), [])
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be provided; a workspace with no subnets cannot host an LPAR."
  }

  validation {
    condition     = length(var.subnets) == length(distinct([for s in var.subnets : s.name]))
    error_message = "subnet names must be unique within the subnets list."
  }

  validation {
    condition     = alltrue([for s in var.subnets : contains(["vlan", "pub-vlan"], s.type)])
    error_message = "each subnet's type must be either \"vlan\" or \"pub-vlan\"."
  }

  validation {
    condition     = alltrue([for s in var.subnets : s.type != "vlan" || can(cidrhost(s.cidr, 0))])
    error_message = "each subnet of type \"vlan\" must have a valid IPv4 CIDR in cidr."
  }
}
