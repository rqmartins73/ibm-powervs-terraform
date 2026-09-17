##############################################################################
# PowerVS Network Module
#
# Creates private (vlan) and public (pub-vlan) subnets in a PowerVS
# workspace that already exists — the workspace itself is created by the
# powervs-workspace module, not here — and optionally attaches those (or
# any other) networks to existing LPAR instances via
# ibm_pi_network_interface, independent of an LPAR's own creation-time
# network blocks (powervs-lpar's `networks` variable).
##############################################################################

locals {
  subnets_by_name = { for s in var.subnets : s.name => s }

  network_attachments_by_key = {
    for a in var.network_attachments :
    "${coalesce(a.subnet_name, a.network_id)}/${a.pvm_instance_id}" => {
      name            = a.name
      network_id      = a.subnet_name != null ? ibm_pi_network.subnet[a.subnet_name].network_id : a.network_id
      pvm_instance_id = a.pvm_instance_id
      ip_address      = a.ip_address
    }
  }
}

resource "ibm_pi_network" "subnet" {
  for_each = local.subnets_by_name

  pi_cloud_instance_id = var.pi_cloud_instance_id
  pi_network_name      = each.value.name
  pi_network_type      = each.value.type
  pi_cidr              = each.value.type == "vlan" ? each.value.cidr : null
  pi_gateway           = each.value.gateway
  pi_dns               = length(each.value.dns) > 0 ? each.value.dns : null
  pi_network_mtu       = each.value.mtu
  pi_enable_dhcp       = each.value.enable_dhcp
  pi_advertise         = each.value.advertise
  pi_arp_broadcast     = each.value.arp_broadcast
}

resource "ibm_pi_network_interface" "attachment" {
  for_each = local.network_attachments_by_key

  pi_cloud_instance_id = var.pi_cloud_instance_id
  pi_network_id        = each.value.network_id
  pi_instance_id       = each.value.pvm_instance_id
  pi_name              = each.value.name
  pi_ip_address        = each.value.ip_address
}
