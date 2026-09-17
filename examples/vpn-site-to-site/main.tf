##############################################################################
# Example: a VPC site-to-site VPN gateway with one on-premises connection,
# a shared IKE policy and a shared IPsec policy.
#
# This is a standalone configuration a stranger can clone and run against
# their own VPC subnet. Every value that would identify a real environment
# is a variable with no environment-specific default.
##############################################################################

module "vpn" {
  source = "../../modules/vpn-site-to-site"

  name              = var.gateway_name
  subnet_id         = var.vpc_subnet_id
  resource_group_id = var.resource_group_id

  ike_policy = {
    name = "${var.gateway_name}-ike-policy"
  }

  ipsec_policy = {
    name = "${var.gateway_name}-ipsec-policy"
  }

  connections = [
    {
      name          = "on-premises"
      peer_address  = var.peer_gateway_address
      preshared_key = var.preshared_key
      local_cidrs   = [var.vpc_cidr]
      peer_cidrs    = [var.peer_cidr]
    }
  ]
}
