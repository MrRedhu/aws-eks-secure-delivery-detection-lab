# Security Controls Matrix

| Phase | Security Control | Tool / Service | Purpose |
|-------|------------------|----------------|---------|
| **Code** | Infrastructure as Code Scanning | Checkov | Prevents insecure AWS configurations from being deployed. |
| **Code** | Secret Scanning | Trivy | Detects hardcoded secrets in the repository files. |
| **Build** | Image Vulnerability Scanning | Trivy | Blocks deployment if the container image contains Critical/High CVEs. |
| **Deploy** | CI/CD Authentication | GitHub OIDC | Replaces long-lived static AWS credentials with short-lived tokens. |
| **Admission** | Kubernetes Policy Validation | Kyverno | Rejects unapproved configurations (e.g., privileged pods, root users) before they run. |
| **Runtime** | App Permissions | IAM IRSA | Limits Pod access to AWS APIs using least-privilege IAM roles. |
| **Runtime** | Threat Detection | GuardDuty | Monitors API logs and runtime activity for malicious behavior. |
| **Runtime** | Posture Management | Security Hub | Assesses the AWS environment against compliance benchmarks. |
| **Response** | Automated Alerting | EventBridge & Lambda | Routes high-severity GuardDuty findings to administrators in real time. |
