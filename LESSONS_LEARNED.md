# Lessons Learned

Building this DevSecOps pipeline provided valuable insights into securing a cloud-native architecture:

1. **Shift-Left Security is Crucial**: Catching vulnerabilities (Trivy) and misconfigurations (Checkov) in the CI/CD pipeline is significantly cheaper and faster than dealing with them after deployment.
2. **Admission Controllers are Powerful**: Relying solely on developers to write secure YAML is risky. Kyverno acts as an un-bypassable gatekeeper at the cluster level.
3. **The Importance of OIDC**: Managing static AWS keys for CI/CD is a major security risk. Implementing GitHub OIDC authentication vastly reduces the attack surface.
4. **Detection is Not Response**: Setting up GuardDuty is only half the battle. Without EventBridge, Lambda, and SNS to parse and route the findings to a human, critical alerts can easily be missed.
5. **Infrastructure as Code**: Terraform modules make it easy to enforce tagging strategies and manage complex IAM relationships (like IRSA) systematically.
