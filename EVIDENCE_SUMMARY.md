# Evidence Summary

This file records the validation evidence collected during the dev deployment. It is intentionally text-based so the repository can be reviewed without AWS console access.

## Deployment Snapshot

| Item | Value |
|------|-------|
| AWS account | `<redacted-account-id>` |
| Region | `us-east-1` |
| Cluster | `aws-eks-secure-delivery-detection-lab-dev` |
| Cluster status | `ACTIVE` |
| Endpoint posture after testing | Public disabled, private enabled |
| Deployed image | `<account-id>.dkr.ecr.us-east-1.amazonaws.com/aws-eks-secure-delivery-detection-lab-dev-api:d1bfc69` |
| Namespace | `secure-demo` |
| Deployment | `secure-demo-api` |
| Service account | `secure-demo-sa` |
| IRSA role | `arn:aws:iam::<account-id>:role/aws-eks-secure-delivery-detection-lab-dev-secure-demo-irsa` |
| Security alert topic | `arn:aws:sns:us-east-1:<account-id>:aws-eks-secure-delivery-detection-lab-dev-security-alerts` |

## Infrastructure Validation

Terraform apply completed successfully and the final drift check returned:

```text
No changes. Your infrastructure matches the configuration.
```

EKS endpoint posture was restored after deployment:

```json
{
  "public": false,
  "private": true,
  "cidrs": [
    "<redacted-workstation-ip>/32"
  ]
}
```

AWS retains the last public CIDR value even when public endpoint access is disabled. The wrapper module now only passes public CIDRs when public access is enabled, so Terraform remains clean while the endpoint stays private.

## Application Deployment Evidence

The workload rolled out successfully:

```text
deployment "secure-demo-api" successfully rolled out
pod/secure-demo-api-54d8d9c4bb-pnpsl   1/1   Running   0
deployment.apps/secure-demo-api        1/1   1         1
```

The in-pod health check returned:

```json
{"status":"ok"}
```

## IRSA Evidence

The running pod had EKS web identity variables injected:

```text
AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token
AWS_ROLE_ARN=arn:aws:iam::<account-id>:role/aws-eks-secure-delivery-detection-lab-dev-secure-demo-irsa
AWS_STS_REGIONAL_ENDPOINTS=regional
```

The service account retained the IRSA annotation while keeping the default Kubernetes token disabled:

```yaml
automountServiceAccountToken: false
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/aws-eks-secure-delivery-detection-lab-dev-secure-demo-irsa
```

## Kyverno Evidence

The secure workload passed all six policies:

```text
secure-demo Deployment secure-demo-api                    PASS 6 FAIL 0 WARN 0 ERROR 0 SKIP 0
secure-demo ReplicaSet  secure-demo-api-54d8d9c4bb         PASS 6 FAIL 0 WARN 0 ERROR 0 SKIP 0
secure-demo Pod         secure-demo-api-54d8d9c4bb-pnpsl   PASS 6 FAIL 0 WARN 0 ERROR 0 SKIP 0
```

ClusterPolicies were ready:

```text
disallow-hostpath                Ready
disallow-privileged-containers   Ready
require-ecr-images               Ready
require-non-root                 Ready
require-readonly-rootfs          Ready
require-resource-limits          Ready
```

The policies exclude platform namespaces such as `kube-system`, `kyverno`, and `amazon-guardduty` so managed control-plane and security-agent workloads are not blocked by application workload standards.

## Local Validation Evidence

```text
terraform validate: Success
pytest: 6 passed
kyverno apply policies/kyverno --resource kubernetes/deployment.yaml: pass 6, fail 0
checkov: Passed checks: 182, Failed checks: 0, Skipped checks: 6
git diff --check: passed
```

Checkov printed a warning about an optional Prisma Cloud guideline lookup failing through the local proxy. The Terraform scan itself completed successfully with zero failed checks.

## Completion Note

The lab is complete for portfolio review. The SNS topic and email subscription are provisioned by Terraform, and the Lambda router is implemented and covered by tests. The final email confirmation click is intentionally skipped because it depends on an inbox-side action rather than repository or infrastructure correctness.
