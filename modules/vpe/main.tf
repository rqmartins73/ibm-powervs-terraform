##############################################################################
# VPE Module
#
# Creates one Virtual Private Endpoint Gateway per entry in
# var.endpoint_gateways, each targeting a provider cloud service by CRN
# (Cloud Object Storage first), with a reserved IP per subnet and the
# binding that attaches each reserved IP to its gateway.
##############################################################################

locals {
  gateways_by_name = { for g in var.endpoint_gateways : g.name => g }

  reserved_ip_keys = merge([
    for gw_name, gw in local.gateways_by_name : {
      for subnet_id in gw.subnet_ids :
      "${gw_name}/${subnet_id}" => {
        gateway_name = gw_name
        subnet_id    = subnet_id
      }
    }
  ]...)
}

resource "ibm_is_virtual_endpoint_gateway" "gateway" {
  for_each = local.gateways_by_name

  name            = each.value.name
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  security_groups = length(each.value.security_group_ids) > 0 ? each.value.security_group_ids : null
  tags            = each.value.tags

  target {
    crn           = each.value.target_crn
    resource_type = "provider_cloud_service"
  }
}

resource "ibm_is_subnet_reserved_ip" "reserved_ip" {
  for_each = local.reserved_ip_keys

  subnet = each.value.subnet_id
  name   = "${each.value.gateway_name}-${substr(each.value.subnet_id, 0, 8)}-ip"
}

resource "ibm_is_virtual_endpoint_gateway_ip" "binding" {
  for_each = local.reserved_ip_keys

  gateway     = ibm_is_virtual_endpoint_gateway.gateway[each.value.gateway_name].id
  reserved_ip = ibm_is_subnet_reserved_ip.reserved_ip[each.key].reserved_ip
}
