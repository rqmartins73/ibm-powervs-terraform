# vpn-site-to-site

Creates a VPC site-to-site VPN gateway, its connections, and their shared
IKE and IPsec policies. **Client-to-site VPN is explicitly out of scope**
for this module — it only manages `ibm_is_vpn_gateway` and connections
of network type site-to-site (peer address/FQDN + local/peer CIDRs), not
`ibm_is_vpn_server`.

This module owns none of the provider configuration: the caller's `ibm`
provider block (API key, region) is used as-is, and must be configured
with the region that owns `subnet_id`.

## What it creates

- `ibm_is_vpn_gateway` — the VPN gateway, attached to an existing VPC subnet.
- `ibm_is_ike_policy` (optional) — a shared IKE policy, when `ike_policy` is set.
- `ibm_is_ipsec_policy` (optional) — a shared IPsec policy, when `ipsec_policy` is set.
- `ibm_is_vpn_gateway_connection` (one per entry in `connections`) — each with its local/peer CIDRs and preshared key, using the shared policies above when provided.

## Usage

```hcl
module "vpn" {
  source = "../../modules/vpn-site-to-site"

  name              = "example-vpn-gateway"
  subnet_id         = var.vpc_subnet_id
  resource_group_id = var.resource_group_id

  ike_policy = {
    name = "example-ike-policy"
  }

  ipsec_policy = {
    name = "example-ipsec-policy"
  }

  connections = [
    {
      name          = "on-premises"
      peer_address  = var.peer_gateway_ip
      preshared_key = var.preshared_key
      local_cidrs   = [var.vpc_cidr]
      peer_cidrs    = [var.on_premises_cidr]
    }
  ]
}
```

See `examples/vpn-site-to-site` for a complete, runnable configuration.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `name` | VPN gateway name (1-63 chars, lowercase/digits/hyphens). | `string` | n/a | yes |
| `subnet_id` | ID of an existing VPC subnet to host the gateway. | `string` | n/a | yes |
| `resource_group_id` | 32-character hex resource group ID. | `string` | n/a | yes |
| `mode` | Gateway mode: `route` or `policy`. | `string` | `"route"` | no |
| `local_asn` | Local ASN for the gateway and its connections. | `number` | `null` | no |
| `tags` | Tags applied to the gateway. | `list(string)` | `[]` | no |
| `ike_policy` | `{ name, authentication_algorithms, encryption_algorithms, dh_groups, ike_version, key_lifetime }`, shared by all connections. `null` to skip. | `object` | `null` | no |
| `ipsec_policy` | `{ name, authentication_algorithms, encryption_algorithms, pfs_groups, key_lifetime }`, shared by all connections. `null` to skip. | `object` | `null` | no |
| `connections` | List of `{ name, peer_address, peer_fqdn, preshared_key, local_cidrs, peer_cidrs, admin_state_up, dpd_action }`; at least one required, exactly one of `peer_address`/`peer_fqdn` per entry. | `list(object)` | n/a | yes |

## Outputs

| Name | Description |
|---|---|
| `vpn_gateway_id` | ID of the VPN gateway. |
| `vpn_gateway_crn` | CRN of the VPN gateway. |
| `vpn_gateway_public_ip_addresses` | Public IP address(es) assigned to the gateway's members — give these to the peer administrator. |
| `ike_policy_id` | ID of the shared IKE policy, or `null`. |
| `ipsec_policy_id` | ID of the shared IPsec policy, or `null`. |
| `connection_ids` | Map of connection name to connection ID. |
| `connection_statuses` | Map of connection name to connection status (`up` or `down`). |
