##############################################################################
# PowerVS LPAR Module
#
# Deploys a single Power Systems Virtual Server instance (LPAR) into an
# existing PowerVS workspace, plus any additional data volumes beyond the
# boot volume that comes from the image.
##############################################################################

resource "ibm_pi_instance" "lpar" {
  pi_cloud_instance_id = var.pi_cloud_instance_id
  pi_instance_name     = var.name

  pi_image_id   = var.image_id
  pi_sys_type   = var.sys_type
  pi_processors = var.processors
  pi_proc_type  = var.proc_type
  pi_memory     = var.memory

  pi_storage_type                    = var.storage_type
  pi_boot_volume_replication_enabled = var.boot_volume_replication_enabled
  pi_pin_policy                      = var.pin_policy
  pi_key_pair_name                   = var.key_pair_name
  pi_user_data                       = var.user_data
  pi_health_status                   = var.health_status
  pi_user_tags                       = var.user_tags

  # IBM i licensing. The provider defaults these to false/0 when the image
  # is not IBM i, so it is safe to always pass them.
  pi_ibmi_css       = var.ibmi_css
  pi_ibmi_pha       = var.ibmi_pha
  pi_ibmi_rds_users = var.ibmi_rds_users

  dynamic "pi_network" {
    for_each = var.networks
    content {
      network_id = pi_network.value.network_id
      ip_address = pi_network.value.ip_address
    }
  }
}

locals {
  volumes_by_name = { for v in var.volumes : v.name => v }
}

resource "ibm_pi_volume" "data" {
  for_each = local.volumes_by_name

  pi_cloud_instance_id = var.pi_cloud_instance_id
  pi_volume_name       = each.value.name
  pi_volume_size       = each.value.size
  pi_volume_type       = coalesce(each.value.tier, var.storage_type, "tier3")
  pi_volume_shareable  = each.value.shareable
}

resource "ibm_pi_volume_attach" "data" {
  for_each = local.volumes_by_name

  pi_cloud_instance_id = var.pi_cloud_instance_id
  pi_instance_id       = ibm_pi_instance.lpar.instance_id
  pi_volume_id         = ibm_pi_volume.data[each.key].volume_id
}

# Volumes that already exist in the workspace. Attached only - never created
# here, so a Terraform destroy detaches them and leaves the data in place.
resource "ibm_pi_volume_attach" "existing" {
  for_each = toset(var.existing_volume_ids)

  pi_cloud_instance_id = var.pi_cloud_instance_id
  pi_instance_id       = ibm_pi_instance.lpar.instance_id
  pi_volume_id         = each.value
}
