##############################################################################
# Example: a Transit Gateway connecting one existing VPC and one existing
# PowerVS workspace.
#
# This is a standalone configuration a stranger can clone and run against
# their own VPC and workspace. Every value that would identify a real
# environment is a variable with no environment-specific default.
##############################################################################

module "transit_gateway" {
  source = "../../modules/transit-gateway"

  name              = var.gateway_name
  location          = var.location
  resource_group_id = var.resource_group_id

  vpc_connections = [
    { name = "${var.gateway_name}-vpc", vpc_crn = var.vpc_crn }
  ]

  powervs_connections = [
    { name = "${var.gateway_name}-powervs", workspace_crn = var.powervs_workspace_crn }
  ]
}
