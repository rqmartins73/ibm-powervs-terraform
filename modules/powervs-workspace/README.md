# powervs-workspace

Creates a PowerVS workspace (a `power-iaas` service instance) in a region/zone
and resource group, with the plan, SSH key and subnets a workspace needs
before any LPAR can be deployed into it.

This module owns none of the provider configuration: the caller's `ibm`
provider block (API key, region, zone) is used as-is. When you go on to
create pi_\* resources against the workspace this module creates (including
with the `powervs-lpar` module), configure that provider with the same
`zone` you pass here.

## What it creates

- `ibm_resource_instance` — the PowerVS workspace itself.
- `ibm_pi_key` (optional) — a workspace-level SSH key, when `ssh_key_public_key` is set.
- `ibm_pi_network` (one per entry in `subnets`) — the private (`vlan`) or public (`pub-vlan`) subnets the workspace needs.

## Usage

```hcl
module "workspace" {
  source = "../../modules/powervs-workspace"

  name              = "example-workspace"
  region            = "eu-de"
  zone              = "eu-de-1"
  resource_group_id = var.resource_group_id

  ssh_key_name        = "example-key"
  ssh_key_public_key  = var.ssh_public_key

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
```

See `examples/powervs-workspace` for a complete, runnable configuration.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `name` | Workspace name (1-63 chars, lowercase/digits/hyphens). | `string` | n/a | yes |
| `region` | IBM Cloud region, for reference/tagging. | `string` | n/a | yes |
| `zone` | PowerVS zone (datacenter) to create the workspace in. | `string` | n/a | yes |
| `resource_group_id` | 32-character hex resource group ID. | `string` | n/a | yes |
| `plan` | Service plan for the workspace. | `string` | `"power-virtual-server-group"` | no |
| `tags` | Tags applied to the workspace. | `list(string)` | `[]` | no |
| `ssh_key_name` | Name for the workspace SSH key. Required if `ssh_key_public_key` is set. | `string` | `null` | no |
| `ssh_key_public_key` | Public key in OpenSSH format to register in the workspace. | `string` | `null` | no |
| `subnets` | List of `{ name, cidr, type, dns }` subnets; at least one required. | `list(object)` | n/a | yes |

## Outputs

| Name | Description |
|---|---|
| `workspace_id` | Resource instance ID of the workspace. |
| `workspace_guid` | Workspace GUID — the value LPAR deployments use as `pi_cloud_instance_id`. |
| `workspace_crn` | CRN of the workspace. |
| `region` | Echo of `var.region`. |
| `zone` | Zone the workspace was created in. |
| `subnet_ids` | Map of subnet name to network ID. |
| `subnet_cidrs` | Map of subnet name to CIDR (`null` for `pub-vlan` subnets). |
| `ssh_key_id` | ID of the workspace SSH key, or `null` if none was created. |
