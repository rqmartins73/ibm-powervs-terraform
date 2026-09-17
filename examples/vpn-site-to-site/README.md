# Example: vpn-site-to-site

Creates one VPC site-to-site VPN gateway, a shared IKE policy, a shared
IPsec policy, and one connection to an on-premises (peer) gateway.

Every value that would identify a real environment is a placeholder —
replace `resource_group_id`, `vpc_subnet_id`, `peer_gateway_address` and
`preshared_key` in your own `terraform.tfvars` before applying.
`peer_gateway_address` and `peer_cidr` default to RFC 5737/1918
documentation ranges — replace them with your real peer's address and
network before applying.

## Run from a CLI

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your resource_group_id, vpc_subnet_id and peer_gateway_address
export TF_VAR_ibmcloud_api_key="..."   # never put this in terraform.tfvars
export TF_VAR_preshared_key="..."      # never put this in terraform.tfvars either

terraform init
terraform plan
terraform apply
```

## Run from IBM Cloud Schematics

Point a Schematics workspace at this directory, set `resource_group_id`,
`vpc_subnet_id`, `peer_gateway_address` and the other variables in the
workspace's variable list, and set `ibmcloud_api_key` and `preshared_key`
as **sensitive** workspace variables rather than in a `.tfvars` file.
Generate the plan, review it, then apply.

## Client-to-site VPN

Not covered here. This module and example only build the VPC site-to-site
VPN gateway (`ibm_is_vpn_gateway`) and its connections — for a
client-to-site VPN server (`ibm_is_vpn_server`), write a separate module.

## Checking connection status

After apply, `terraform output connection_statuses` shows whether the
tunnel actually came up (`up` or `down`) — useful once the peer side has
been configured with the gateway's public IP address(es), from
`terraform output vpn_gateway_public_ip_addresses`.
