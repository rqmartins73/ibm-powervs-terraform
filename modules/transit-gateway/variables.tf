##############################################################################
# Transit Gateway Module - Variables
#
# The provider block is owned by the caller. Unlike PowerVS and VPC,
# Transit Gateway has no regional API host — it is a single global service
# (https://transit.cloud.ibm.com) — so var.location below is metadata
# attached to the gateway resource, not something that has to match the
# caller's configured provider region.
##############################################################################

variable "name" {
  description = "Name of the transit gateway. Must be 1-63 characters, lowercase letters, digits and hyphens only, and cannot start or end with a hyphen."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "name must be 1-63 characters, lowercase letters/digits/hyphens only, and cannot start or end with a hyphen."
  }
}

variable "location" {
  description = "IBM Cloud location metadata for the gateway (e.g. eu-de, eu-es, us-south). This does not select an API endpoint — Transit Gateway is a single global service — it only records where the gateway is considered to be located."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*(-[a-z0-9]+)*$", var.location))
    error_message = "location must be lowercase alphanumeric segments separated by hyphens (e.g. eu-de, us-south)."
  }
}

variable "global" {
  description = "Whether the gateway routes across regions (true) or is confined to its location's region (false)."
  type        = bool
  default     = false
}

variable "gre_enhanced_route_propagation" {
  description = "Allow route propagation across all GRE connections on this gateway (redundant_gre, unbound_gre_tunnel, gre_tunnel connection types)."
  type        = bool
  default     = false
}

variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group the gateway is created in (32-character hex string, as returned by `ibmcloud resource groups`)."
  type        = string

  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "resource_group_id must be the 32-character hexadecimal resource group ID, not its name."
  }
}

variable "tags" {
  description = "Tags to apply to the gateway."
  type        = list(string)
  default     = []
}

variable "vpc_connections" {
  description = <<-EOT
    VPC connections to create on this gateway.

    - name:    connection name, unique within the list.
    - vpc_crn: CRN of the VPC to connect.
  EOT
  type = list(object({
    name    = string
    vpc_crn = string
  }))
  default = []

  validation {
    condition     = length(var.vpc_connections) == length(distinct([for c in var.vpc_connections : c.name]))
    error_message = "vpc_connections names must be unique within the list."
  }

  validation {
    condition     = alltrue([for c in var.vpc_connections : can(regex("^crn:", c.vpc_crn))])
    error_message = "each vpc_connections entry's vpc_crn must be a CRN (starting with \"crn:\")."
  }
}

variable "powervs_connections" {
  description = <<-EOT
    PowerVS workspace connections to create on this gateway.

    - name:          connection name, unique within the list.
    - workspace_crn: CRN of the PowerVS workspace to connect (e.g. the
                      workspace_crn output of the powervs-workspace module).
  EOT
  type = list(object({
    name          = string
    workspace_crn = string
  }))
  default = []

  validation {
    condition     = length(var.powervs_connections) == length(distinct([for c in var.powervs_connections : c.name]))
    error_message = "powervs_connections names must be unique within the list."
  }

  validation {
    condition     = alltrue([for c in var.powervs_connections : can(regex("^crn:", c.workspace_crn))])
    error_message = "each powervs_connections entry's workspace_crn must be a CRN (starting with \"crn:\")."
  }
}
