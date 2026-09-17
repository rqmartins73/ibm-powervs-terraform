# transit-gateway

Creates an IBM Cloud Transit Gateway and its connections to VPCs and
PowerVS workspaces. Connection status is surfaced as an output so the
caller (or the desktop application) can tell whether a connection actually
came up without a separate lookup.

This module owns none of the provider configuration. Transit Gateway is a
single global IBM Cloud service with no regional API host, so — unlike the
`powervs-workspace` and `powervs-network` modules — the caller's provider
`region` does not need to match `var.location`; `location` is metadata
recorded on the gateway, not an endpoint selector.

## What it creates

- `ibm_tg_gateway` — the transit gateway itself.
- `ibm_tg_connection` (one per entry in `vpc_connections`) — `network_type = "vpc"` connections, by VPC CRN.
- `ibm_tg_connection` (one per entry in `powervs_connections`) — `network_type = "power_virtual_server"` connections, by PowerVS workspace CRN.

## Usage

```hcl
module "transit_gateway" {
  source = "../../modules/transit-gateway"

  name              = "example-tgw"
  location          = "eu-de"
  resource_group_id = var.resource_group_id

  vpc_connections = [
    { name = "vpc-hub", vpc_crn = var.vpc_crn }
  ]

  powervs_connections = [
    { name = "powervs-workspace", workspace_crn = module.workspace.workspace_crn }
  ]
}
```

See `examples/transit-gateway` for a complete, runnable configuration.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `name` | Gateway name (1-63 chars, lowercase/digits/hyphens). | `string` | n/a | yes |
| `location` | Location metadata for the gateway (e.g. eu-de, eu-es). Not an API endpoint selector. | `string` | n/a | yes |
| `global` | Whether the gateway routes across regions. | `bool` | `false` | no |
| `gre_enhanced_route_propagation` | Route propagation across GRE connections on this gateway. | `bool` | `false` | no |
| `resource_group_id` | 32-character hex resource group ID. | `string` | n/a | yes |
| `tags` | Tags applied to the gateway. | `list(string)` | `[]` | no |
| `vpc_connections` | List of `{ name, vpc_crn }` VPC connections. | `list(object)` | `[]` | no |
| `powervs_connections` | List of `{ name, workspace_crn }` PowerVS workspace connections. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|---|---|
| `transit_gateway_id` | ID of the gateway. |
| `transit_gateway_crn` | CRN of the gateway. |
| `transit_gateway_status` | Configuration status of the gateway. |
| `vpc_connection_ids` | Map of VPC connection name to connection ID. |
| `vpc_connection_statuses` | Map of VPC connection name to connection status. |
| `powervs_connection_ids` | Map of PowerVS connection name to connection ID. |
| `powervs_connection_statuses` | Map of PowerVS connection name to connection status. |
