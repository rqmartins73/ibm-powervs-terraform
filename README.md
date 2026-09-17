# ibm-powervs-terraform

Terraform modules for IBM Cloud PowerVS: the workspace (service instance,
resource group, SSH key, subnets) and the LPARs deployed into it (AIX, IBM i
or Linux). Written to be run from **IBM Cloud Schematics** or from any local
Terraform CLI — neither module declares a backend, so state ownership is up
to whoever runs it.

## Modules

| Module | Purpose |
|---|---|
| [`modules/powervs-workspace`](modules/powervs-workspace) | Creates a PowerVS workspace in a region/zone/resource group, with its plan, SSH key and subnets. |
| [`modules/powervs-lpar`](modules/powervs-lpar) | Deploys an LPAR into an existing workspace: image, processors, memory, storage tier, volumes, networks, SSH key, and AIX/IBM i/Linux specifics. |

`powervs-workspace` comes first: its `workspace_guid` and `subnet_ids`
outputs are what `powervs-lpar` (and anything else built into this
workspace) consumes as input.

Each module has a matching runnable example under [`examples/`](examples)
with its own README and `terraform.tfvars.example`. No file in this
repository — module, example, default, or comment — names a real IBM Cloud
account, resource group, workspace, LPAR, bucket or IP address.

## Requirements

- Terraform `>= 1.5.0, < 2.0.0`
- The `IBM-Cloud/ibm` provider, `>= 1.75.0, < 3.0.0`
- An IBM Cloud API key with permission to create PowerVS resources in the target resource group

## Running from a CLI

```bash
cd examples/powervs-workspace   # or examples/powervs-lpar
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your own resource group / workspace / key values
export TF_VAR_ibmcloud_api_key="..."   # never put an API key in a .tfvars file

terraform init
terraform plan
terraform apply
```

## Running from IBM Cloud Schematics

Neither module nor example declares a `backend` block — Schematics manages
state on its own, so there is nothing to remove or reconfigure.

1. Create a Schematics workspace and point it at this repository, with the
   Terraform template set to the module or example directory you want to run
   (e.g. `examples/powervs-workspace`).
2. Set the workspace's input variables to your own values (resource group
   ID, zone, subnets, image, etc. — see each example's README for the full
   list).
3. Set `ibmcloud_api_key` as a **sensitive** Schematics workspace variable,
   not as a value in a committed `.tfvars` file.
4. Generate a plan, review what it says it will create, then apply.

## Repository layout

```
modules/
  powervs-workspace/   # workspace, SSH key, subnets
  powervs-lpar/        # LPAR into an existing workspace
examples/
  powervs-workspace/   # standalone, runnable example
  powervs-lpar/        # standalone, runnable example
```

## Contributing

Pull requests should keep the two rules above: no backend block, and no
value anywhere that identifies a real environment. Run
`terraform fmt -recursive` and `terraform validate` (with
`terraform init -backend=false`) in every module and example you touch
before opening a PR.

## License

Apache License 2.0 — see [LICENSE](LICENSE).

---

**Ricardo Martins** — IBM Power Technical Leader
IBM Champion 2025/2026
Blue Chip Portugal
[github.com/rqmartins73](https://github.com/rqmartins73)
