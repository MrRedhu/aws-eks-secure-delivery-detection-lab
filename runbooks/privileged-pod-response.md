# Runbook: Privileged Pod Response

**Trigger**: Kyverno admission controller blocks a deployment and returns an error regarding privileged escalation.

## 1. Triage
1. Review the Kubernetes manifest being deployed.
2. Identify the `securityContext` block that is violating the cluster policy.

## 2. Remediation
1. Modify the `deployment.yaml` to ensure:
   - `privileged: false`
   - `allowPrivilegeEscalation: false`
   - `runAsNonRoot: true`
2. Ensure the container process is designed to run without root privileges.

## 3. Verification
1. Re-apply the manifest:
   ```bash
   kubectl apply -f deployment.yaml
   ```
2. Verify the Pod transitions to the `Running` state without admission errors.
