# Example: vpe

Creates one Virtual Private Endpoint Gateway to Cloud Object Storage in an
existing VPC, with a reserved IP on one subnet.

Every value that would identify a real environment is a placeholder —
replace `resource_group_id`, `vpc_id`, `subnet_id` and `cos_endpoint_crn`
in your own `terraform.tfvars` before applying. `cos_endpoint_crn` in the
template is IBM's own documented endpoint shape for `eu-de`, not an
account-specific value — replace the region segment (and re-check the
exact CRN) for the region you are actually deploying in.

## Run from a CLI

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your resource_group_id, vpc_id, subnet_id and cos_endpoint_crn
export TF_VAR_ibmcloud_api_key="..."   # never put this in terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Run from IBM Cloud Schematics

Point a Schematics workspace at this directory, set `resource_group_id`,
`vpc_id`, `subnet_id`, `cos_endpoint_crn` and the other variables in the
workspace's variable list, and set `ibmcloud_api_key` as a sensitive
workspace variable rather than in a `.tfvars` file. Generate the plan,
review it, then apply.

## Reaching more than one service

Add more entries to the `endpoint_gateways` list in `main.tf` — one per
service (e.g. Key Protect, a Databases for PostgreSQL deployment) — each
with its own `name` and `target_crn`.
