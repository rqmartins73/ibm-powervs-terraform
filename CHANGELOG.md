# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-09-17

### Added
- `modules/powervs-workspace` and `modules/powervs-lpar`, each with a runnable example.
- `modules/powervs-network`, `modules/transit-gateway`, `modules/vpn-site-to-site` and `modules/vpe`,
  each with a runnable example and a committed provider lock file.
- Every module validates with `terraform init -backend=false && terraform validate`. None has been
  applied against a real account yet.

## [Unreleased]

### Added
- `modules/powervs-workspace`: creates the PowerVS workspace (service instance), an optional
  workspace SSH key, and its subnets. Outputs workspace id, GUID, CRN, region, zone and subnet IDs.
- `modules/powervs-lpar`: deploys an LPAR (AIX, IBM i or Linux) into an existing workspace, with
  processors, memory, storage tier, boot volume behaviour, additional data volumes, networks, SSH
  key and IBM i licensing inputs.
- `examples/powervs-workspace` and `examples/powervs-lpar`: standalone, runnable examples with
  placeholder-only values and a `terraform.tfvars.example` each.
- Repository skeleton: Apache-2.0 `LICENSE`, `.gitignore`, this `CHANGELOG.md`.
