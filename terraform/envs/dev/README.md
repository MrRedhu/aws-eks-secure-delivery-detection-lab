# Dev Environment

This directory is the runnable Terraform root for the lab.

Run `../bootstrap` first. The dev root uses the S3/DynamoDB backend created by
the bootstrap stack.

## Required variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and set:

- `alert_email`: SNS email endpoint for GuardDuty and budget notifications.
- `cluster_endpoint_public_access`: keep `false` for the hardened posture, or set `true` temporarily for GitHub-hosted runner or workstation `kubectl` access.
- `cluster_endpoint_public_access_cidrs`: when public access is enabled, use one or more `/32` CIDRs.

## Safe command order

```bash
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform fmt -check -recursive ../..
terraform validate -no-color
terraform plan
```

Run `terraform apply` only after reviewing the plan and confirming the cost impact.

## Outputs used by deployment

- `cluster_name`
- `ecr_repository_url`
- `app_irsa_role_arn`
- `security_alerts_topic_arn`

## GitHub-hosted runner access

The cluster endpoint is private by default. Use a self-hosted runner in the VPC,
or pass a short-lived `/32` CIDR list to the deploy workflow input
`cluster_endpoint_public_access_cidrs`.
