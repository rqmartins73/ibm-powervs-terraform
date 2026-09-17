# Example: powervs-network

Creates a private (`management`) and a public (`public`) subnet in a PowerVS
workspace that already exists, then attaches the public subnet to an
existing LPAR instance after the fact.

Every value that would identify a real environment is a placeholder —
replace `pi_cloud_instance_id` and `existing_lpar_instance_id` in your own
`terraform.tfvars` before applying.

## Run from a CLI

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your workspace GUID and an existing LPAR instance ID
export TF_VAR_ibmcloud_api_key="..."   # never put this in terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Run from IBM Cloud Schematics

Point a Schematics workspace at this directory, set `pi_cloud_instance_id`,
`existing_lpar_instance_id` and the other variables in the workspace's
variable list, and set `ibmcloud_api_key` as a sensitive workspace variable
rather than in a `.tfvars` file. Generate the plan, review it — it should
show two subnets and one network interface attachment being created — then
apply.

## No existing LPAR to attach to?

Drop the `network_attachments` block from `main.tf` (or set it to `[]`) if
you only want the two subnets and have no existing LPAR instance ID to
attach the public one to yet.
