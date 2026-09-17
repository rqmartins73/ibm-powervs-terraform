##############################################################################
# Example: a Virtual Private Endpoint Gateway to Cloud Object Storage in an
# existing VPC.
#
# This is a standalone configuration a stranger can clone and run against
# their own VPC and subnet. Every value that would identify a real
# environment is a variable with no environment-specific default.
##############################################################################

module "vpe" {
  source = "../../modules/vpe"

  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id

  endpoint_gateways = [
    {
      name       = "cos"
      target_crn = var.cos_endpoint_crn
      subnet_ids = [var.subnet_id]
    }
  ]
}
