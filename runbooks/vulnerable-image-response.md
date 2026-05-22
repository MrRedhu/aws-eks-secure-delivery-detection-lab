# Runbook: Vulnerable Image Response

**Trigger**: Trivy fails the GitHub Actions CI pipeline due to a Critical or High CVE.

## 1. Triage
1. Review the GitHub Actions logs for the `trivy` step.
2. Identify the specific CVE, the vulnerable library, and the recommended fixed version.

## 2. Remediation
1. Update the base image in the `Dockerfile` to a newer patch version, OR
2. Update the specific dependency in `requirements.txt`.
3. Commit the changes and push to trigger the pipeline again.

## 3. Verification
1. Ensure the GitHub Actions pipeline now passes the Trivy scan.
2. Merge the code and allow deployment to proceed.
