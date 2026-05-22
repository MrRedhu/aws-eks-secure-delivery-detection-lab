# Runbook: CI Supply Chain Incident Response

**Trigger**: A third-party GitHub Action or Docker Base Image used in our CI pipeline is compromised.

## 1. Triage
1. Identify the compromised action or image from threat intelligence feeds.
2. Search the repository workflows to determine if the compromised version was used.

## 2. Containment
1. Immediately revoke any AWS OIDC roles or credentials that the compromised action may have had access to.
2. Stop all running GitHub Actions workflows.

## 3. Remediation
1. Update the `.github/workflows/*.yml` files to pin the action to a known-safe commit SHA, or replace the action entirely.
2. Audit the AWS CloudTrail logs for any unauthorized API calls made by the GitHub Actions OIDC role during the window of compromise.

## 4. Verification
1. Re-run the pipelines using the secured, pinned action versions.
2. Confirm CloudTrail logs show no further suspicious activity.
