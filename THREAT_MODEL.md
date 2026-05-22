# Threat Model

This document outlines the primary threats mitigated by the architecture of this lab.

## Attack Vector 1: Malicious or Compromised CI/CD
**Threat**: An attacker gains access to the GitHub repository and attempts to deploy vulnerable code or steal AWS credentials.
**Mitigation**: 
- OIDC is used instead of static AWS access keys, eliminating long-lived credentials.
- `Trivy` scans the repository for accidentally committed secrets.

## Attack Vector 2: Supply Chain & Vulnerable Dependencies
**Threat**: The application includes a third-party library with a known Critical CVE.
**Mitigation**:
- `Trivy` scans the Docker image during the GitHub Action workflow. The build fails and deployment is halted if High or Critical CVEs are detected.

## Attack Vector 3: Cloud Infrastructure Misconfiguration
**Threat**: A developer accidentally modifies Terraform to make the ECR repository public or disable encryption.
**Mitigation**:
- `Checkov` analyzes the Terraform code on every Pull Request and blocks the merge if standard security controls are violated.

## Attack Vector 4: Container Escape / Privilege Escalation
**Threat**: An attacker exploits the application and attempts to escape the container to access the underlying EC2 worker node.
**Mitigation**:
- `Kyverno` policies reject the creation of any Pod that requests `privileged: true`, runs as the `root` user, or attempts to mount the host filesystem.

## Attack Vector 5: Runtime Exploitation & Lateral Movement
**Threat**: An attacker successfully executes a reverse shell inside the container.
**Mitigation**:
- `GuardDuty EKS Runtime Monitoring` detects the anomalous execution behavior, triggers an EventBridge rule, and alerts the administrator via Lambda and SNS.
