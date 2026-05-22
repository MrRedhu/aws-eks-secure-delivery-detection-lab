# Skills

This file documents the skills and automated workflows associated with this project.

No custom Codex skills are packaged in this repository.

## Project Workflows

- **Terraform bootstrap**: one-time creation of the S3 remote state bucket, DynamoDB lock table, and GitHub Actions OIDC role from `terraform/bootstrap`.
- **Terraform dev environment**: EKS, ECR, KMS, AWS Config, CloudTrail, Security Hub, GuardDuty, EventBridge, Lambda, SNS, and budget provisioning from `terraform/envs/dev`.
- **Secure delivery checks**: pytest, Trivy filesystem/image scans, Checkov Terraform scan, and Kyverno CLI validation through GitHub Actions.
- **Kubernetes admission control**: Kyverno policies enforce non-root containers, no privileged pods, read-only root filesystems, resource requests/limits, no hostPath volumes, and ECR-only images.
- **Detection and response**: GuardDuty EKS/runtime findings route through EventBridge to Lambda and SNS, with runbooks under `runbooks/`.

## Local Validation Commands

- `make validate`
- `make test`
- `make scan-iac`
- `make scan-image`
- `make scan-k8s`
