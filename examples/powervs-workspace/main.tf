##############################################################################
# Example: a PowerVS workspace with two private subnets and an SSH key.
#
# This is a standalone configuration a stranger can clone and run. Every
# value that would identify a real environment (resource group, SSH key,
# workspace name) is a variable with no environment-specific default.
##############################################################################

module "workspace" {
  source = "../../modules/powervs-workspace"

  name              = var.workspace_name
  region            = var.region
  zone              = var.zone
  resource_group_id = var.resource_group_id

  ssh_key_name       = "${var.workspace_name}-key"
  ssh_key_public_key = var.ssh_public_key

  tags = ["example", "powervs-workspace"]

  subnets = [
    {
      name = "management"
      cidr = "10.51.0.0/24"
    },
    {
      name = "data"
      cidr = "10.51.1.0/24"
    }
  ]
}
