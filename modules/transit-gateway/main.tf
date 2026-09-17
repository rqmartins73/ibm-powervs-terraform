##############################################################################
# Transit Gateway Module
#
# Creates a Transit Gateway and its connections to VPCs and PowerVS
# workspaces. Both connection types attach by CRN, so the VPC or PowerVS
# workspace itself is created elsewhere (e.g. by the powervs-workspace
# module) and passed in.
##############################################################################

locals {
  vpc_connections_by_name     = { for c in var.vpc_connections : c.name => c }
  powervs_connections_by_name = { for c in var.powervs_connections : c.name => c }
}

resource "ibm_tg_gateway" "gateway" {
  name                           = var.name
  location                       = var.location
  global                         = var.global
  gre_enhanced_route_propagation = var.gre_enhanced_route_propagation
  resource_group                 = var.resource_group_id
  tags                           = var.tags
}

resource "ibm_tg_connection" "vpc" {
  for_each = local.vpc_connections_by_name

  gateway      = ibm_tg_gateway.gateway.id
  name         = each.value.name
  network_type = "vpc"
  network_id   = each.value.vpc_crn
}

resource "ibm_tg_connection" "powervs" {
  for_each = local.powervs_connections_by_name

  gateway      = ibm_tg_gateway.gateway.id
  name         = each.value.name
  network_type = "power_virtual_server"
  network_id   = each.value.workspace_crn
}
