##############################################################################
# VPN Site-to-Site Module - Variables
#
# The provider block is owned by the caller, and must be configured with
# the VPC region that owns var.subnet_id. Client-to-site VPN is explicitly
# out of scope for this module — it only manages the VPC site-to-site VPN
# gateway, its connections, and their IKE/IPsec policies.
##############################################################################

variable "name" {
  description = "Name of the VPN gateway. Must be 1-63 characters, lowercase letters, digits and hyphens only, and cannot start or end with a hyphen."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "name must be 1-63 characters, lowercase letters/digits/hyphens only, and cannot start or end with a hyphen."
  }
}

variable "subnet_id" {
  description = "ID of an existing VPC subnet to host the VPN gateway. This module does not create the VPC or subnet."
  type        = string

  validation {
    condition     = length(var.subnet_id) > 0
    error_message = "subnet_id must not be empty."
  }
}

variable "resource_group_id" {
  description = "ID of the IBM Cloud resource group the gateway and its policies are created in (32-character hex string, as returned by `ibmcloud resource groups`)."
  type        = string

  validation {
    condition     = can(regex("^[a-f0-9]{32}$", var.resource_group_id))
    error_message = "resource_group_id must be the 32-character hexadecimal resource group ID, not its name."
  }
}

variable "mode" {
  description = "VPN gateway mode: \"route\" (route-based) or \"policy\" (policy-based)."
  type        = string
  default     = "route"

  validation {
    condition     = contains(["route", "policy"], var.mode)
    error_message = "mode must be either \"route\" or \"policy\"."
  }
}

variable "local_asn" {
  description = "Local autonomous system number (ASN) for the VPN gateway and its connections. Leave null to let the platform assign one."
  type        = number
  default     = null

  validation {
    condition     = var.local_asn == null || (var.local_asn >= 1 && var.local_asn <= 4294967294)
    error_message = "local_asn, when set, must be between 1 and 4294967294."
  }
}

variable "tags" {
  description = "Tags to apply to the VPN gateway."
  type        = list(string)
  default     = []
}

variable "ike_policy" {
  description = <<-EOT
    IKE policy shared by all connections on this gateway. Leave null to skip
    creating one and let each connection negotiate IKE parameters with the
    platform default policy instead.
  EOT
  type = object({
    name                      = string
    authentication_algorithms = optional(list(string), ["sha256"])
    encryption_algorithms     = optional(list(string), ["aes256"])
    dh_groups                 = optional(list(number), [14])
    ike_version               = optional(number, 2)
    key_lifetime              = optional(number, 28800)
  })
  default = null

  validation {
    condition     = var.ike_policy == null || can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.ike_policy.name))
    error_message = "ike_policy.name, when set, must be 1-63 characters, lowercase letters/digits/hyphens only, and cannot start or end with a hyphen."
  }

  validation {
    condition = var.ike_policy == null || alltrue([
      for a in var.ike_policy.authentication_algorithms : contains(["sha256", "sha384", "sha512"], a)
    ])
    error_message = "ike_policy.authentication_algorithms entries must be one of: sha256, sha384, sha512."
  }

  validation {
    condition = var.ike_policy == null || alltrue([
      for a in var.ike_policy.encryption_algorithms : contains(["aes128", "aes192", "aes256"], a)
    ])
    error_message = "ike_policy.encryption_algorithms entries must be one of: aes128, aes192, aes256."
  }

  validation {
    condition = var.ike_policy == null || alltrue([
      for g in var.ike_policy.dh_groups : contains([14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 31], g)
    ])
    error_message = "ike_policy.dh_groups entries must be one of: 14-24, 31."
  }

  validation {
    condition     = var.ike_policy == null || contains([1, 2], var.ike_policy.ike_version)
    error_message = "ike_policy.ike_version must be 1 or 2."
  }

  validation {
    condition     = var.ike_policy == null || (var.ike_policy.key_lifetime >= 1800 && var.ike_policy.key_lifetime <= 86400)
    error_message = "ike_policy.key_lifetime must be between 1800 and 86400 seconds."
  }
}

variable "ipsec_policy" {
  description = <<-EOT
    IPsec policy shared by all connections on this gateway. Leave null to
    skip creating one and let each connection negotiate IPsec parameters
    with the platform default policy instead.
  EOT
  type = object({
    name                      = string
    authentication_algorithms = optional(list(string), ["sha256"])
    encryption_algorithms     = optional(list(string), ["aes256"])
    pfs_groups                = optional(list(string), ["group_14"])
    key_lifetime              = optional(number, 3600)
  })
  default = null

  validation {
    condition     = var.ipsec_policy == null || can(regex("^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$", var.ipsec_policy.name))
    error_message = "ipsec_policy.name, when set, must be 1-63 characters, lowercase letters/digits/hyphens only, and cannot start or end with a hyphen."
  }

  validation {
    condition = var.ipsec_policy == null || alltrue([
      for a in var.ipsec_policy.authentication_algorithms : contains(["sha256", "sha384", "sha512", "disabled"], a)
    ])
    error_message = "ipsec_policy.authentication_algorithms entries must be one of: sha256, sha384, sha512, disabled."
  }

  validation {
    condition = var.ipsec_policy == null || alltrue([
      for a in var.ipsec_policy.encryption_algorithms : contains(["aes128", "aes192", "aes256", "aes128gcm16", "aes192gcm16", "aes256gcm16"], a)
    ])
    error_message = "ipsec_policy.encryption_algorithms entries must be one of: aes128, aes192, aes256, aes128gcm16, aes192gcm16, aes256gcm16."
  }

  validation {
    condition = var.ipsec_policy == null || alltrue([
      for g in var.ipsec_policy.pfs_groups : contains([
        "disabled", "group_14", "group_15", "group_16", "group_17", "group_18",
        "group_19", "group_20", "group_21", "group_22", "group_23", "group_24", "group_31"
      ], g)
    ])
    error_message = "ipsec_policy.pfs_groups entries must be one of: disabled, group_14-24, group_31."
  }

  validation {
    condition     = var.ipsec_policy == null || (var.ipsec_policy.key_lifetime >= 300 && var.ipsec_policy.key_lifetime <= 86400)
    error_message = "ipsec_policy.key_lifetime must be between 300 and 86400 seconds."
  }
}

variable "connections" {
  description = <<-EOT
    Site-to-site VPN connections to create on this gateway. Client-to-site
    VPN is out of scope for this module.

    Each entry must set exactly one of peer_address or peer_fqdn.

    - name:           connection name, unique within the list.
    - peer_address:   IP address of the peer VPN gateway.
    - peer_fqdn:      FQDN of the peer VPN gateway.
    - preshared_key:  preshared key for the connection (at least 6 characters, per the platform minimum).
    - local_cidrs:    CIDRs on this side of the tunnel to route over it.
    - peer_cidrs:     CIDRs on the peer side of the tunnel to route over it.
    - admin_state_up: whether the connection is administratively up. Defaults to true.
    - dpd_action:     dead peer detection action: restart, clear, hold, or none. Defaults to restart.
  EOT
  type = list(object({
    name           = string
    peer_address   = optional(string)
    peer_fqdn      = optional(string)
    preshared_key  = string
    local_cidrs    = list(string)
    peer_cidrs     = list(string)
    admin_state_up = optional(bool, true)
    dpd_action     = optional(string, "restart")
  }))

  validation {
    condition     = length(var.connections) > 0
    error_message = "At least one connection must be provided."
  }

  validation {
    condition     = length(var.connections) == length(distinct([for c in var.connections : c.name]))
    error_message = "connections names must be unique within the list."
  }

  validation {
    condition     = alltrue([for c in var.connections : (c.peer_address != null) != (c.peer_fqdn != null)])
    error_message = "each connection must set exactly one of peer_address or peer_fqdn."
  }

  validation {
    condition     = alltrue([for c in var.connections : length(c.preshared_key) >= 6])
    error_message = "each connection's preshared_key must be at least 6 characters."
  }

  validation {
    condition     = alltrue([for c in var.connections : length(c.local_cidrs) > 0 && alltrue([for cidr in c.local_cidrs : can(cidrhost(cidr, 0))])])
    error_message = "each connection's local_cidrs must be a non-empty list of valid IPv4 CIDRs."
  }

  validation {
    condition     = alltrue([for c in var.connections : length(c.peer_cidrs) > 0 && alltrue([for cidr in c.peer_cidrs : can(cidrhost(cidr, 0))])])
    error_message = "each connection's peer_cidrs must be a non-empty list of valid IPv4 CIDRs."
  }

  validation {
    condition     = alltrue([for c in var.connections : contains(["restart", "clear", "hold", "none"], c.dpd_action)])
    error_message = "each connection's dpd_action must be one of: restart, clear, hold, none."
  }
}
