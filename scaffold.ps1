$ErrorActionPreference = "Stop"
$directories = @(
    "app/src",
    "app/tests",
    "terraform/modules/vpc",
    "terraform/modules/eks",
    "terraform/modules/ecr",
    "terraform/modules/iam",
    "terraform/modules/kms",
    "terraform/modules/cloudtrail",
    "terraform/modules/aws-config",
    "terraform/modules/securityhub",
    "terraform/modules/guardduty",
    "terraform/modules/detection-routing",
    "terraform/modules/budget",
    "terraform/envs/dev",
    "kubernetes/intentionally-insecure",
    "policies/kyverno",
    "policies/checkov",
    "policies/trivy",
    "lambda/guardduty_finding_router/tests",
    "evidence/screenshots",
    "evidence/checkov-before-after",
    "evidence/trivy-before-after",
    "evidence/kyverno-policy-results",
    "evidence/guardduty-findings",
    "evidence/securityhub-controls",
    "evidence/eventbridge-routing",
    "evidence/runbook-walkthrough",
    "runbooks",
    ".github/workflows"
)

foreach ($dir in $directories) {
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
}

$files = @(
    "README.md",
    "PROJECT_BRIEF.md",
    "ARCHITECTURE.md",
    "THREAT_MODEL.md",
    "CONTROLS_MATRIX.md",
    "COST_AND_CLEANUP.md",
    "LESSONS_LEARNED.md",
    "PORTFOLIO_CASE_STUDY.md",
    "SECURITY_NOTES.md",
    "Makefile",
    "app/Dockerfile",
    "app/requirements.txt",
    "app/pyproject.toml",
    "app/src/main.py",
    "app/tests/test_health.py",
    "terraform/backend.tf",
    "terraform/providers.tf",
    "terraform/variables.tf",
    "terraform/outputs.tf",
    "terraform/versions.tf",
    "terraform/main.tf",
    "terraform/envs/dev/main.tf",
    "terraform/envs/dev/terraform.tfvars.example",
    "terraform/envs/dev/README.md",
    "kubernetes/namespace.yaml",
    "kubernetes/service-account.yaml",
    "kubernetes/deployment.yaml",
    "kubernetes/service.yaml",
    "kubernetes/ingress.yaml",
    "kubernetes/network-policy.yaml",
    "kubernetes/hardened-deployment.yaml",
    "kubernetes/intentionally-insecure/privileged-pod.yaml",
    "kubernetes/intentionally-insecure/root-container.yaml",
    "kubernetes/intentionally-insecure/no-resource-limits.yaml",
    "kubernetes/intentionally-insecure/wrong-registry.yaml",
    "policies/kyverno/disallow-privileged.yaml",
    "policies/kyverno/require-non-root.yaml",
    "policies/kyverno/require-readonly-rootfs.yaml",
    "policies/kyverno/require-resource-limits.yaml",
    "policies/kyverno/disallow-hostpath.yaml",
    "policies/kyverno/require-image-registry.yaml",
    "policies/checkov/custom-required-tags.yaml",
    "policies/trivy/trivy.yaml",
    "lambda/guardduty_finding_router/handler.py",
    "lambda/guardduty_finding_router/requirements.txt",
    "lambda/guardduty_finding_router/tests/test_handler.py",
    "runbooks/guardduty-eks-finding-triage.md",
    "runbooks/vulnerable-image-response.md",
    "runbooks/privileged-pod-response.md",
    "runbooks/ci-supply-chain-incident-response.md",
    ".github/workflows/pr-security-checks.yml",
    ".github/workflows/terraform-plan.yml",
    ".github/workflows/deploy-dev.yml",
    ".github/workflows/destroy-dev.yml",
    ".github/dependabot.yml"
)

foreach ($file in $files) {
    if (-not (Test-Path -Path $file)) {
        New-Item -ItemType File -Force -Path $file | Out-Null
    }
}

Write-Host "Scaffolding complete!"
