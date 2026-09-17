# powervs-network

Creates private (`vlan`) and public (`pub-vlan`) subnets in a PowerVS
workspace that **already exists** — this module does not create the
workspace itself, see `powervs-workspace` for that — and optionally attaches
those (or any other) networks to existing LPAR instances.

This module owns none of the provider configuration: the caller's `ibm`
provider block (API key, region, zone) is used as-is, and must be configured
with the same zone as the workspace identified by `pi_cloud_instance_id`.

## What it creates

- `ibm_pi_network` (one per entry in `subnets`) — the private or public subnets, with DNS, gateway, MTU and PER advertise/ARP-broadcast options.
- `ibm_pi_network_interface` (one per entry in `network_attachments`) — attaches a network to an existing LPAR instance after the fact, independent of that LPAR's own creation-time network blocks.

## Why network attachment lives here, not in powervs-lpar

`powervs-lpar` attaches networks to an LPAR at creation time, through its
`networks` variable and the instance's own `pi_network` blocks. This module
instead uses `ibm_pi_network_interface`, which attaches (or detaches) a
network from an LPAR that already exists, without touching the LPAR
resource. Use this when you need to add or change networking on an LPAR
after it has been deployed, or when networking is being managed as a
separate concern from compute.

## Usage

```hcl
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
      subnet_name     = "public"
      pvm_instance_id = var.existing_lpar_instance_id
    }
  ]
}
```

See `examples/powervs-network` for a complete, runnable configuration.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `pi_cloud_instance_id` | GUID of the existing PowerVS workspace. | `string` | n/a | yes |
| `subnets` | List of `{ name, type, cidr, gateway, dns, mtu, enable_dhcp, advertise, arp_broadcast }` subnets; at least one required. | `list(object)` | n/a | yes |
| `network_attachments` | List of `{ name, subnet_name, network_id, pvm_instance_id, ip_address }` post-creation network attachments to existing LPARs; exactly one of `subnet_name`/`network_id` per entry. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|---|---|
| `subnet_ids` | Map of subnet name to network ID. |
| `subnet_cidrs` | Map of subnet name to CIDR (`null` for `pub-vlan` subnets). |
| `subnet_crns` | Map of subnet name to CRN. |
| `subnet_vlan_ids` | Map of subnet name to the underlying VLAN ID. |
| `network_attachment_ids` | Map of `network_id/pvm_instance_id` to the network interface ID. |
| `network_attachment_ip_addresses` | Map of `network_id/pvm_instance_id` to the assigned IP address. |
