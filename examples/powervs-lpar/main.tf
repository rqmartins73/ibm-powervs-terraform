##############################################################################
# Example: an IBM i LPAR deployed into an existing PowerVS workspace.
#
# This is a standalone configuration a stranger can clone and run against
# their own workspace. It looks up the boot image by name with the
# ibm_pi_catalog_images data source so no image ID has to be hardcoded.
##############################################################################

data "ibm_pi_catalog_images" "images" {
  pi_cloud_instance_id = var.pi_cloud_instance_id
}

locals {
  boot_image = one([
    for image in data.ibm_pi_catalog_images.images.images : image
    if image.name == var.image_name
  ])
}

module "lpar" {
  source = "../../modules/powervs-lpar"

  pi_cloud_instance_id = var.pi_cloud_instance_id

  name     = var.lpar_name
  os_type  = "ibmi"
  image_id = local.boot_image.image_id
  sys_type = "s922"

  processors = 0.5
  proc_type  = "shared"
  memory     = 4

  storage_type  = "tier3"
  key_pair_name = var.key_pair_name

  networks = [
    { network_id = var.network_id }
  ]

  volumes = [
    {
      name = "${var.lpar_name}-data"
      size = 50
    }
  ]

  user_tags = ["example", "powervs-lpar"]
}
