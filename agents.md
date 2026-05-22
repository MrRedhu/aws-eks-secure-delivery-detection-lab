# Agents

This file tracks the autonomous agents utilized or defined within this repository. 

No custom executable agents are defined in this repository.

## Operating Roles

The project now uses these documented operating roles during implementation and review:

- **Infrastructure reviewer**: audits Terraform bootstrap, remote state, EKS, IAM, GuardDuty, Security Hub, AWS Config, CloudTrail, budget, and cleanup behavior.
- **Delivery pipeline reviewer**: audits GitHub Actions, OIDC authentication, image build/push, Terraform plan/apply/destroy, and scanner configuration.
- **Kubernetes policy reviewer**: audits namespace, service account, deployment hardening, network policies, Kyverno policies, and intentionally insecure evidence manifests.
- **Detection reviewer**: audits GuardDuty finding routing, EventBridge rules, Lambda formatting, SNS notification, and incident-response runbooks.

These are human/AI review roles, not background services or deployed agents.
