##############################################################################
# PowerVS Workspace Module
#
# Creates a PowerVS workspace (a "power-iaas" resource instance), an
# optional SSH key registered in that workspace, and the subnets the
# workspace needs before any LPAR can be deployed into it.
##############################################################################

resource "ibm_resource_instance" "workspace" {
  name              = var.name
  service           = "power-iaas"
  plan              = var.plan
  location          = var.zone
  resource_group_id = var.resource_group_id
  tags              = var.tags
}

resource "ibm_pi_key" "workspace_key" {
  count = var.ssh_key_public_key != null ? 1 : 0

  pi_cloud_instance_id = ibm_resource_instance.workspace.guid
  pi_key_name          = var.ssh_key_name
  pi_ssh_key           = var.ssh_key_public_key
}

locals {
  subnets_by_name = { for s in var.subnets : s.name => s }
}

resource "ibm_pi_network" "subnet" {
  for_each = local.subnets_by_name

  pi_cloud_instance_id = ibm_resource_instance.workspace.guid
  pi_network_name      = each.value.name
  pi_network_type      = each.value.type
  pi_cidr              = each.value.type == "vlan" ? each.value.cidr : null
  pi_dns               = length(each.value.dns) > 0 ? each.value.dns : null
}
