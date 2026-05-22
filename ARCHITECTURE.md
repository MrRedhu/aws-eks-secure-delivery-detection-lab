# Architecture

This document breaks down the components of the secure delivery pipeline and the AWS runtime environment.

## 1. Secure CI/CD Pipeline
- **GitHub Actions**: Orchestrates the build and deployment.
- **Checkov**: Scans Terraform code (IaC) for misconfigurations (e.g., unencrypted ECR).
- **Trivy**: Scans the application filesystem for hardcoded secrets, and the Docker image for Critical/High CVEs.
- **Kyverno CLI**: Validates Kubernetes manifests against security policies prior to deployment.

## 2. AWS Infrastructure
- **Amazon EKS**: The core Kubernetes environment running managed EC2 nodes.
- **Amazon ECR**: A private container registry to store our validated images.
- **IAM (OIDC & IRSA)**: Uses GitHub OIDC for passwordless CI/CD authentication. Uses IAM Roles for Service Accounts (IRSA) to grant least-privilege AWS access to Kubernetes pods.
- **AWS KMS**: Encrypts Kubernetes secrets at rest.

## 3. Threat Detection Pipeline
- **Amazon GuardDuty**: Continuously monitors EKS audit logs and runtime behavior.
- **AWS Security Hub**: Aggregates security posture findings.
- **Amazon EventBridge**: Catches GuardDuty findings with a severity of 7.0 or higher.
- **AWS Lambda**: A custom Python function that parses EventBridge payloads and formats them for human readability.
- **Amazon SNS**: Dispatches the formatted alert to the security administrator.
