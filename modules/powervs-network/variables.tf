##############################################################################
# PowerVS Network Module - Variables
#
# The provider block is owned by the caller, and must be configured with
# the region/zone of the workspace identified by pi_cloud_instance_id. This
# module only declares the ibm provider requirement in versions.tf. This
# module does not create the workspace itself — see powervs-workspace.
##############################################################################

variable "pi_cloud_instance_id" {
  description = "GUID of the existing PowerVS workspace to create subnets in (the workspace_guid output of the powervs-workspace module)."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.pi_cloud_instance_id))
    error_message = "pi_cloud_instance_id must be a UUID (the workspace GUID), not a workspace name or CRN."
  }
}

variable "subnets" {
  description = <<-EOT
    Subnets (PowerVS networks) to create in the workspace.

    - name:          subnet name, unique within the list.
    - type:          "vlan" (private) or "pub-vlan" (public). Defaults to "vlan".
    - cidr:          subnet CIDR in IPv4 notation (e.g. 10.51.0.0/24). Required when type is "vlan".
    - gateway:       optional gateway IP address for the subnet. Leave null to let the platform
                      derive it from cidr.
    - dns:           optional list of DNS server IPs. Leave empty for the platform default
                      (127.0.0.1 for vlan, 9.9.9.9 for pub-vlan).
    - mtu:           optional MTU override, 1450-9000. Leave null for the platform default.
    - enable_dhcp:   whether the subnet runs DHCP. Defaults to true.
    - advertise:     "enable" or "disable" — PER route advertisement, vlan networks on
                      PER-enabled workspaces only. Leave null to accept the platform default.
    - arp_broadcast: "enable" or "disable" — ARP broadcast, vlan networks on PER-enabled
                      workspaces only. Leave null to accept the platform default.
  EOT
  type = list(object({
    name          = string
    type          = optional(string, "vlan")
    cidr          = optional(string)
    gateway       = optional(string)
    dns           = optional(list(string), [])
    mtu           = optional(number)
    enable_dhcp   = optional(bool, true)
    advertise     = optional(string)
    arp_broadcast = optional(string)
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be provided."
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
    condition     = alltrue([for s in var.subnets : s.type != "vlan" || (s.cidr != null && can(cidrhost(s.cidr, 0)))])
    error_message = "each subnet of type \"vlan\" must have a valid IPv4 CIDR in cidr."
  }

  validation {
    condition     = alltrue([for s in var.subnets : s.cidr == null || can(cidrhost(s.cidr, 0))])
    error_message = "cidr, when set, must be a valid IPv4 CIDR."
  }

  validation {
    condition = alltrue([
      for s in var.subnets : s.gateway == null || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", s.gateway))
    ])
    error_message = "each subnet's gateway, when set, must be a valid IPv4 address."
  }

  validation {
    condition = alltrue([
      for s in var.subnets : s.mtu == null || (s.mtu >= 1450 && s.mtu <= 9000)
    ])
    error_message = "each subnet's mtu, when set, must be between 1450 and 9000."
  }

  validation {
    condition = alltrue([
      for s in var.subnets : s.advertise == null || contains(["enable", "disable"], s.advertise)
    ])
    error_message = "each subnet's advertise, when set, must be \"enable\" or \"disable\"."
  }

  validation {
    condition = alltrue([
      for s in var.subnets : s.arp_broadcast == null || contains(["enable", "disable"], s.arp_broadcast)
    ])
    error_message = "each subnet's arp_broadcast, when set, must be \"enable\" or \"disable\"."
  }
}

variable "network_attachments" {
  description = <<-EOT
    Attaches a network to an existing LPAR instance after the fact, using
    ibm_pi_network_interface. This is deliberately independent of instance
    creation: use it to attach a network to an LPAR managed by the
    powervs-lpar module, or by anything else, without touching that LPAR's
    own resource.

    Each entry must set exactly one of subnet_name or network_id:

    - name:            optional display name for the network interface.
    - subnet_name:     name of a subnet created by this same module call
                        (a key in var.subnets) to attach.
    - network_id:      ID of a network created elsewhere (outside this
                        module call) to attach.
    - pvm_instance_id: ID of the LPAR instance to attach the network to.
    - ip_address:      optional static IP to request; leave null to let the
                        platform assign one.
  EOT
  type = list(object({
    name            = optional(string)
    subnet_name     = optional(string)
    network_id      = optional(string)
    pvm_instance_id = string
    ip_address      = optional(string)
  }))
  default = []

  validation {
    condition     = alltrue([for a in var.network_attachments : (a.subnet_name != null) != (a.network_id != null)])
    error_message = "each network_attachments entry must set exactly one of subnet_name or network_id."
  }

  validation {
    condition = alltrue([
      for a in var.network_attachments : a.subnet_name == null || contains([for s in var.subnets : s.name], a.subnet_name)
    ])
    error_message = "network_attachments[*].subnet_name, when set, must match a name in var.subnets."
  }

  validation {
    condition = length(var.network_attachments) == length(distinct([
      for a in var.network_attachments : "${coalesce(a.subnet_name, a.network_id)}/${a.pvm_instance_id}"
    ]))
    error_message = "each network_attachments entry must be a unique (subnet_name or network_id, pvm_instance_id) pair."
  }
}
