##############################################################################
# Example: a private and a public subnet in an existing PowerVS workspace,
# with the public subnet attached to an existing LPAR after the fact.
#
# This is a standalone configuration a stranger can clone and run against
# their own workspace. Every value that would identify a real environment
# is a variable with no environment-specific default.
##############################################################################

module "network" {
  source = "../../modules/powervs-network"

  pi_cloud_instance_id = var.pi_cloud_instance_id

  subnets = [
    {
      name    = "management"
      type    = "vlan"
      cidr    = "10.52.0.0/24"
      gateway = "10.52.0.1"
      dns     = ["10.52.0.2"]
    },
    {
      name = "public"
      type = "pub-vlan"
    }
  ]

  network_attachments = [
    {
      name            = "public-attach"
      subnet_name     = "public"
      pvm_instance_id = var.existing_lpar_instance_id
    }
  ]
}
