##############################################################################
# VPN Site-to-Site Module
#
# Creates a VPC site-to-site VPN gateway, an optional shared IKE policy, an
# optional shared IPsec policy, and one connection per entry in
# var.connections. Client-to-site VPN (ibm_is_vpn_server) is explicitly out
# of scope here.
##############################################################################

resource "ibm_is_vpn_gateway" "gateway" {
  name           = var.name
  subnet         = var.subnet_id
  mode           = var.mode
  resource_group = var.resource_group_id
  tags           = var.tags
  local_asn      = var.local_asn
}

resource "ibm_is_ike_policy" "ike" {
  count = var.ike_policy != null ? 1 : 0

  name                      = var.ike_policy.name
  authentication_algorithms = var.ike_policy.authentication_algorithms
  encryption_algorithms     = var.ike_policy.encryption_algorithms
  dh_groups                 = var.ike_policy.dh_groups
  ike_version               = var.ike_policy.ike_version
  key_lifetime              = var.ike_policy.key_lifetime
  resource_group            = var.resource_group_id
}

resource "ibm_is_ipsec_policy" "ipsec" {
  count = var.ipsec_policy != null ? 1 : 0

  name                      = var.ipsec_policy.name
  authentication_algorithms = var.ipsec_policy.authentication_algorithms
  encryption_algorithms     = var.ipsec_policy.encryption_algorithms
  pfs_groups                = var.ipsec_policy.pfs_groups
  key_lifetime              = var.ipsec_policy.key_lifetime
  resource_group            = var.resource_group_id
}

locals {
  connections_by_name = { for c in var.connections : c.name => c }
}

resource "ibm_is_vpn_gateway_connection" "connection" {
  for_each = local.connections_by_name

  name           = each.value.name
  vpn_gateway    = ibm_is_vpn_gateway.gateway.id
  preshared_key  = each.value.preshared_key
  admin_state_up = each.value.admin_state_up
  action         = each.value.dpd_action

  ike_policy   = try(ibm_is_ike_policy.ike[0].id, null)
  ipsec_policy = try(ibm_is_ipsec_policy.ipsec[0].id, null)

  local {
    cidrs = each.value.local_cidrs
  }

  peer {
    address = each.value.peer_address
    fqdn    = each.value.peer_fqdn
    cidrs   = each.value.peer_cidrs
  }
}
