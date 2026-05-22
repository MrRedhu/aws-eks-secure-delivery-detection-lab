# Portfolio Review Guide

This guide helps a reviewer evaluate the project quickly without needing AWS access.

## Fast Review Path

1. Start with [README.md](README.md) for the architecture and current verified state.
2. Read [PORTFOLIO_CASE_STUDY.md](PORTFOLIO_CASE_STUDY.md) for the problem, design decisions, and outcomes.
3. Check [CONTROLS_MATRIX.md](CONTROLS_MATRIX.md) for the security controls and where they are implemented.
4. Review [EVIDENCE_SUMMARY.md](EVIDENCE_SUMMARY.md) for deployment and validation proof.
5. Inspect the highest-signal implementation files:
   - `terraform/modules/eks/main.tf`
   - `terraform/envs/dev/main.tf`
   - `.github/workflows/deploy-dev.yml`
   - `policies/kyverno/`
   - `kubernetes/deployment.yaml`
   - `lambda/guardduty_finding_router/src/handler.py`

## What To Look For

| Skill Area | Evidence |
|------------|----------|
| AWS security architecture | Private EKS endpoint, KMS encryption, CloudTrail, AWS Config, Security Hub, GuardDuty |
| DevSecOps | GitHub Actions gates for tests, Trivy, Checkov, and Kyverno |
| Identity | GitHub OIDC and EKS IRSA instead of long-lived static keys |
| Kubernetes hardening | Non-root pod, read-only filesystem, seccomp, no privilege escalation, network policy |
| Detection engineering | GuardDuty high-severity EventBridge rule and Lambda finding router |
| Operational maturity | Runbooks, cleanup guidance, budget alerts, evidence summary |

## Design Tradeoffs

- The lab uses a single dev account and deliberately keeps some broad bootstrap permissions for setup speed. The risky parts are documented and isolated to the lab context.
- EKS is private by default. Temporary public endpoint access can be enabled for a single `/32` during local testing and then disabled again.
- Kyverno workload policies exclude platform namespaces to avoid breaking managed components such as GuardDuty agents.
- AWS Config recorder creation is optional because many AWS accounts already have a default recorder and delivery channel.

## Demo Script

Use this script for a short verbal walkthrough:

1. "The repo starts with secure delivery controls: tests, IaC scan, image scan, secret scan, and manifest policy checks."
2. "Terraform provisions the secure runtime: private EKS, ECR, KMS, GuardDuty, Security Hub, CloudTrail, and SNS alerting."
3. "GitHub deploys through OIDC; the pod uses IRSA, so neither CI nor workloads need static credentials."
4. "Kyverno enforces the workload contract at admission time."
5. "Runtime findings flow through GuardDuty, EventBridge, Lambda, and SNS."
6. "The evidence summary shows the live deployment and validation outputs."
