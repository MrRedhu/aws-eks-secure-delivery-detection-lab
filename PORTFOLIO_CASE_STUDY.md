# Portfolio Case Study

## Project: AWS EKS Secure Delivery & Detection Lab

### The Problem
Organizations need a way to ship containerized workloads quickly without allowing insecure infrastructure, vulnerable images, overprivileged pods, or missed runtime threats into production-like environments.

### The Solution
I engineered an end-to-end AWS EKS lab that combines preventative DevSecOps controls with runtime detection and alert routing.

- **Prevention**: Checkov scans Terraform, Trivy scans the repository and container image, and Kyverno blocks unsafe Kubernetes workloads at admission time.
- **Identity**: GitHub Actions authenticates to AWS with OIDC, and the application pod uses IRSA rather than inheriting node credentials.
- **Runtime Security**: The EKS workload runs as non-root with a read-only root filesystem, dropped capabilities, seccomp, resource limits, and network policy.
- **Detection**: GuardDuty EKS protection and Security Hub monitor runtime and posture signals.
- **Response**: EventBridge routes high-severity GuardDuty findings to a Python Lambda formatter, which publishes alerts to SNS.

### The Results
- Deployed and validated the dev environment in AWS.
- Rolled out the hardened `secure-demo-api` workload from private ECR.
- Verified IRSA injection in the running pod.
- Verified Kyverno policy status and confirmed the secure-demo workload passes all six policy checks.
- Restored the EKS API endpoint to private-only access after the deployment window.
- Achieved local validation results of `6 passed` unit tests and `182 passed, 0 failed` Checkov checks.

### Key Engineering Decisions
- Kept the EKS endpoint private by default and used short-lived `/32` public access only for local deployment testing.
- Made EKS admin access explicit through Terraform-managed access entries so GitHub and local deployment access are auditable.
- Installed Kyverno with server-side apply to avoid large CRD client-side annotation limits.
- Scoped Kyverno application policies away from platform namespaces to avoid blocking managed AWS security agents.
- Preserved AWS account compatibility by making AWS Config recorder creation optional.

### What I Would Improve Next
- Add a self-hosted GitHub runner in the VPC so deployment never requires a temporary public endpoint.
- Add optional sanitized console screenshots to supplement the existing text evidence.
- Replace broad lab bootstrap permissions with a more granular deployment role once the lab is stable.
