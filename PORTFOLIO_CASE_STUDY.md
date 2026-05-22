# Portfolio Case Study

## Project: AWS EKS Secure Delivery & Detection Lab

### The Problem
Organizations often struggle to balance deployment speed with security. Traditional security gates slow down developers, while a lack of runtime monitoring leaves cloud environments vulnerable to post-breach exploitation.

### The Solution
I engineered an automated, end-to-end DevSecOps pipeline that enforces security without hindering developer velocity.

- **Prevention**: I implemented Checkov for IaC scanning and Trivy for container vulnerability scanning within GitHub Actions. I then configured Kyverno as a Kubernetes admission controller to prevent privileged escalations.
- **Detection**: I deployed Amazon GuardDuty to monitor EKS runtime behavior and AWS Security Hub for posture management.
- **Response**: I wrote a custom AWS Lambda function, triggered by EventBridge, to parse high-severity GuardDuty findings and alert the team via SNS in real-time.

### The Results
- Eliminated the need for static AWS credentials in CI/CD by leveraging GitHub OIDC.
- Ensured 100% of deployed containers are scanned for CVEs prior to entering the ECR registry.
- Established a robust detection pipeline capable of identifying and alerting on runtime threats (e.g., container escapes) within seconds.
