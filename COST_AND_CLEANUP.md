# Cost and Cleanup

## AWS Costs
Running this lab on AWS will incur hourly charges. The primary cost drivers are:
- **Amazon EKS Control Plane**: ~$0.10 per hour.
- **NAT Gateway (if enabled)**: ~$0.045 per hour + data processing.
- **EC2 Worker Nodes**: Depends on instance type (e.g., t3.medium is ~$0.04 per hour).
- **GuardDuty**: Billed based on the volume of logs analyzed.

We have implemented an **AWS Budget** to alert you if the monthly spending exceeds a predefined threshold (default $20).

## Cleanup Instructions
To stop incurring charges, you must destroy the infrastructure when you are done testing.

1. If the EKS endpoint is private and you are outside the VPC, temporarily enable a scoped `/32` access window or run cleanup from a VPC-connected host.

2. Destroy the Kubernetes resources if you want a clean app teardown before Terraform:
   ```bash
   kubectl delete -f kubernetes/network-policy.yaml
   kubectl delete -f kubernetes/service.yaml
   kubectl delete -f kubernetes/deployment.yaml
   kubectl delete -f kubernetes/service-account.yaml
   kubectl delete -f kubernetes/namespace.yaml
   ```

3. Destroy the AWS infrastructure:
   ```bash
   terraform -chdir=terraform/envs/dev destroy -auto-approve
   ```

Verify in the AWS Console that the EKS Cluster, NAT Gateways, and Load Balancers have been fully removed.
