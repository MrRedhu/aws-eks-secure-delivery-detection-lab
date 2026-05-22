# Bootstrap

This stack is run once from a workstation with AWS administrator credentials.
It creates:

- S3 bucket for Terraform remote state.
- DynamoDB table for Terraform state locking.
- GitHub Actions OIDC provider and deploy role.

## Run

```bash
cd terraform/bootstrap
terraform init
terraform apply
terraform output backend_config
```

Copy the `backend_config` output into `terraform/envs/dev/backend.hcl`, or let
the GitHub workflows generate the same backend settings from the AWS account ID.

After bootstrap succeeds, GitHub Actions can assume the generated role and use
the remote backend for the dev environment.
