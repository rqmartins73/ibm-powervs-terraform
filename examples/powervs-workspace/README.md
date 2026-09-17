# Example: powervs-workspace

Creates one PowerVS workspace with two private subnets and a workspace SSH
key. Every value that would identify a real environment is a placeholder —
replace `resource_group_id` and `ssh_public_key` in your own
`terraform.tfvars` before applying.

## Run from a CLI

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your resource_group_id and ssh_public_key
export TF_VAR_ibmcloud_api_key="..."   # never put this in terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Run from IBM Cloud Schematics

Point a Schematics workspace at this directory (or the repository, with
this as the Terraform template folder), set `resource_group_id`,
`ssh_public_key` and the other variables in the workspace's variable list,
and set `ibmcloud_api_key` as a sensitive workspace variable rather than in
a `.tfvars` file. Generate the plan, review it, then apply.
