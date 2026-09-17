# Example: powervs-lpar

Deploys one IBM i LPAR into a PowerVS workspace that already exists (for
instance, one created with the `powervs-workspace` example), attaching one
network and one extra 50 GiB data volume. The boot image is looked up by
name with `ibm_pi_catalog_images` so no image ID needs to be hardcoded.

Every value that would identify a real environment is a placeholder —
replace `pi_cloud_instance_id`, `network_id` and `key_pair_name` in your
own `terraform.tfvars` before applying.

## Run from a CLI

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your workspace GUID, network ID and SSH key name
export TF_VAR_ibmcloud_api_key="..."   # never put this in terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Run from IBM Cloud Schematics

Point a Schematics workspace at this directory, set `pi_cloud_instance_id`,
`network_id`, `key_pair_name` and the other variables in the workspace's
variable list, and set `ibmcloud_api_key` as a sensitive workspace variable
rather than in a `.tfvars` file. Generate the plan, review it — it should
show one LPAR, one volume and one volume attachment being created — then
apply.

## Deploying AIX or Linux instead

Set `os_type = "aix"` or `os_type = "linux"` in the module block, pick a
matching `image_name`/`sys_type`, and drop the `ibmi_*` variables (they are
rejected by the module's validation unless `os_type = "ibmi"`).
