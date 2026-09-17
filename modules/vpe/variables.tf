##############################################################################
# VPE Module - Variables
#
# The provider block is owned by the caller. This module creates Virtual
# Private Endpoint Gateways in an existing VPC so that resources in that
# VPC — including a PowerVS workspace reached through a Transit Gateway
# connection — can reach IBM Cloud services (COS first) privately, without
# traversing the public network.
##############################################################################

variable "vpc_id" {
  description = "ID of the existing VPC to create the endpoint gateways in."
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id must not be empty."
  }
}

variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group the endpoint gateways are created in (32-character hex string, as returned by `ibmcloud resource groups`)."
  type        = string

  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "resource_group_id must be the 32-character hexadecimal resource group ID, not its name."
  }
}

variable "endpoint_gateways" {
  description = <<-EOT
    Virtual Private Endpoint Gateways to create, one per service the VPC
    needs to reach privately (Cloud Object Storage first).

    - name:                gateway name, unique within the list.
    - target_crn:          CRN of the service endpoint to connect to (e.g. a
                            regional COS "direct" endpoint CRN). Look this up
                            per-region rather than hardcoding one — it differs
                            by service and IBM Cloud region.
    - subnet_ids:           subnets to reserve a private IP on for this gateway; at least one required.
    - security_group_ids:  optional security groups to attach to the gateway.
    - tags:                optional tags for this gateway.
  EOT
  type = list(object({
    name               = string
    target_crn         = string
    subnet_ids         = list(string)
    security_group_ids = optional(list(string), [])
    tags               = optional(list(string), [])
  }))

  validation {
    condition     = length(var.endpoint_gateways) > 0
    error_message = "At least one endpoint gateway must be provided."
  }

  validation {
    condition     = length(var.endpoint_gateways) == length(distinct([for g in var.endpoint_gateways : g.name]))
    error_message = "endpoint_gateways names must be unique within the list."
  }

  validation {
    condition     = alltrue([for g in var.endpoint_gateways : can(regex("^crn:", g.target_crn))])
    error_message = "each endpoint_gateways entry's target_crn must be a CRN (starting with \"crn:\")."
  }

  validation {
    condition     = alltrue([for g in var.endpoint_gateways : length(g.subnet_ids) > 0])
    error_message = "each endpoint_gateways entry must have at least one subnet ID."
  }
}
