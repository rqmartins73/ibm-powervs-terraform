# vpe

Creates Virtual Private Endpoint (VPE) Gateways in an existing VPC for the
IBM Cloud services a PowerVS workspace's VPC-side resources need to reach
privately — Cloud Object Storage first, but any service reachable by
`target { crn, resource_type = "provider_cloud_service" }` works the same
way.

This module owns none of the provider configuration: the caller's `ibm`
provider block (API key, region) is used as-is.

## What it creates

- `ibm_is_virtual_endpoint_gateway` (one per entry in `endpoint_gateways`) — the VPE gateway, targeting the service by CRN.
- `ibm_is_subnet_reserved_ip` (one per gateway/subnet pair) — the private IP reserved on each subnet the gateway is exposed on.
- `ibm_is_virtual_endpoint_gateway_ip` (one per gateway/subnet pair) — the binding that attaches each reserved IP to its gateway.

## Finding a service's target CRN

A service's private endpoint CRN is region-specific and looked up per
service (for COS, the "direct" regional endpoint CRN;
`crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.<region>.cloud-object-storage.appdomain.cloud`
is the general COS shape). Do not hardcode one in this module — pass it in
through `target_crn`.

## Usage

```hcl
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
```

See `examples/vpe` for a complete, runnable configuration.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `vpc_id` | ID of the existing VPC. | `string` | n/a | yes |
| `resource_group_id` | 32-character hex resource group ID. | `string` | n/a | yes |
| `endpoint_gateways` | List of `{ name, target_crn, subnet_ids, security_group_ids, tags }`; at least one required. | `list(object)` | n/a | yes |

## Outputs

| Name | Description |
|---|---|
| `gateway_ids` | Map of gateway name to gateway ID. |
| `gateway_crns` | Map of gateway name to gateway CRN. |
| `gateway_health_states` | Map of gateway name to health state. |
| `reserved_ip_addresses` | Map of `gateway_name/subnet_id` to the reserved private IP address. |
