# powervs-lpar

Deploys a single LPAR (Power Systems Virtual Server instance) into an
existing PowerVS workspace — AIX, IBM i or Linux — with its processors,
memory, storage tier, networks, SSH key, boot volume behaviour and any
extra data volumes.

This is the one module that does not exist anywhere else in the owner's
repositories; every input is documented below because there is no prior
version to defer to.

## What it creates

- `ibm_pi_instance` — the LPAR itself, one `pi_network` block per entry in `networks`.
- `ibm_pi_volume` (one per entry in `volumes`) — additional data volumes beyond the boot volume that comes from the image.
- `ibm_pi_volume_attach` (one per volume) — attaches each data volume to the LPAR.

The provider block is owned by the caller and must be configured for the
same region/zone as the workspace identified by `pi_cloud_instance_id`.

## Usage

```hcl
module "lpar" {
  source = "../../modules/powervs-lpar"

  pi_cloud_instance_id = module.workspace.workspace_guid

  name     = "example-lpar"
  os_type  = "ibmi"
  image_id = data.ibm_pi_image.boot.id
  sys_type = "s922"

  processors = 0.5
  proc_type  = "shared"
  memory     = 4

  storage_type  = "tier3"
  key_pair_name = "example-key"

  networks = [
    { network_id = module.workspace.subnet_ids["management"] }
  ]

  volumes = [
    { name = "example-lpar-data", size = 50 }
  ]
}
```

See `examples/powervs-lpar` for a complete, runnable configuration,
including how to look up `image_id` with a data source.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `pi_cloud_instance_id` | Workspace GUID (UUID) to deploy into. | `string` | n/a | yes |
| `name` | LPAR name (1-47 chars, lowercase/digits/hyphens). | `string` | n/a | yes |
| `os_type` | `aix`, `ibmi` or `linux`. Gates the `ibmi_*` variables. | `string` | n/a | yes |
| `image_id` | ID of the boot image (look up with `ibm_pi_image`/`ibm_pi_catalog_images`). | `string` | n/a | yes |
| `sys_type` | Host system type (e.g. `s922`, `e980`, `s1022`). | `string` | n/a | yes |
| `processors` | vCPUs assigned to the LPAR; fractional for shared/capped. | `number` | n/a | yes |
| `proc_type` | `shared`, `capped` or `dedicated`. | `string` | `"shared"` | no |
| `memory` | Memory in GiB. | `number` | n/a | yes |
| `storage_type` | Boot/default volume tier: `tier0`, `tier1`, `tier3`, `tier5k`, or `null` for the platform default. | `string` | `null` | no |
| `boot_volume_replication_enabled` | Enable replication on the boot volume. | `bool` | `false` | no |
| `pin_policy` | `none`, `soft` or `hard`. | `string` | `"none"` | no |
| `key_pair_name` | Name of an SSH key already registered in the workspace. | `string` | `null` | no |
| `networks` | List of `{ network_id, ip_address }`; at least one required. | `list(object)` | n/a | yes |
| `volumes` | List of `{ name, size, tier, shareable }` additional data volumes. | `list(object)` | `[]` | no |
| `user_data` | cloud-init user data (plain text or base64). Sensitive. | `string` | `null` | no |
| `health_status` | `OK` or `WARNING` — the health Terraform waits for. | `string` | `"OK"` | no |
| `user_tags` | Tags applied to the LPAR. | `list(string)` | `[]` | no |
| `ibmi_css` | IBM i Cloud Storage Solution flag. Only allowed when `os_type = "ibmi"`. | `bool` | `false` | no |
| `ibmi_pha` | IBM i Power High Availability flag. Only allowed when `os_type = "ibmi"`. | `bool` | `false` | no |
| `ibmi_rds_users` | IBM i Rational Dev Studio user license count. Only allowed when `os_type = "ibmi"`. | `number` | `0` | no |

## Outputs

| Name | Description |
|---|---|
| `id` | Terraform resource ID of the LPAR. |
| `instance_id` | Instance ID within the workspace. |
| `crn` | CRN of the LPAR. |
| `status` | Last observed status. |
| `health_status` | Last observed health status. |
| `networks` | Attached networks, including assigned IP/MAC addresses. |
| `volume_ids` | Map of data volume name to volume ID. |

## Notes

- `sys_type` availability varies per zone; check what a given PowerVS
  datacenter offers before picking one.
- The boot volume's size comes from the image, not from a variable here;
  `storage_type` controls its tier, not its size.
- Deploying an IBM i LPAR without setting `os_type = "ibmi"` still works,
  but the `ibmi_*` license variables are then locked to their defaults.
