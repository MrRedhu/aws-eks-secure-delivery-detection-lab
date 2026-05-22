# Security Notes

## Supply Chain Pinning
To mitigate CI/CD supply chain risks, this project implements strict version pinning:
- **Trivy GitHub Action**: We avoid using floating tags (like `@master` or `@v1`) for the AquaSecurity Trivy action to prevent upstream poisoning from executing malicious code in our CI runner.

## Infrastructure Security
- **OIDC**: Short-lived OIDC tokens are used for AWS authentication instead of long-lived, static IAM user keys.
- **KMS**: EKS Secrets are encrypted at rest using an AWS KMS Customer Managed Key.
- **IRSA**: Pods assume least-privilege IAM Roles for Service Accounts (IRSA) rather than inheriting EC2 node privileges.
