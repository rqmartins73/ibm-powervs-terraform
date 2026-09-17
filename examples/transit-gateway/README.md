# Example: transit-gateway

Creates one Transit Gateway with a connection to an existing VPC and a
connection to an existing PowerVS workspace.

Every value that would identify a real environment is a placeholder —
replace `resource_group_id`, `vpc_crn` and `powervs_workspace_crn` in your
own `terraform.tfvars` before applying.

## Run from a CLI

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your resource_group_id, vpc_crn and powervs_workspace_crn
export TF_VAR_ibmcloud_api_key="..."   # never put this in terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Run from IBM Cloud Schematics

Point a Schematics workspace at this directory, set `resource_group_id`,
`vpc_crn`, `powervs_workspace_crn` and the other variables in the
workspace's variable list, and set `ibmcloud_api_key` as a sensitive
workspace variable rather than in a `.tfvars` file. Generate the plan,
review it, then apply.

## Checking connection status

After apply, `terraform output vpc_connection_statuses` and
`terraform output powervs_connection_statuses` show each connection's
status (e.g. `attached`, `pending`, `failed`) without a separate API call —
useful for confirming a cross-account or cross-region connection actually
came up.
