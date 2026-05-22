# Runbook: GuardDuty EKS Finding Triage

**Trigger**: An SNS alert is received stating that Amazon GuardDuty has detected an anomaly in the EKS cluster.

## 1. Triage
1. Open the AWS GuardDuty Console in the specified region.
2. Review the specific finding details (e.g., `Execution:Kubernetes/ExecInKubeSystemPod`, `PrivilegeEscalation:Kubernetes/PrivilegedContainer`).
3. Identify the affected Pod name, namespace, and container ID.

## 2. Containment
1. If the behavior is malicious, immediately isolate the pod:
   ```bash
   kubectl label pod <pod-name> -n <namespace> quarantine=true
   ```
   The `secure-demo` NetworkPolicies exclude pods with `quarantine=true` from the normal ingress and egress allow rules, leaving the default deny policy in effect.
2. Do NOT delete the pod immediately, to preserve forensic evidence.

## 3. Remediation
1. Identify how the attacker gained access (e.g., exposed vulnerability in the container image).
2. Patch the vulnerability in the source code.
3. Deploy the patched image via the CI/CD pipeline.
4. Delete the quarantined pod.

## 4. Verification
1. Monitor GuardDuty for 24 hours to ensure the finding does not reoccur.
2. Ensure the patched deployment is running successfully.
