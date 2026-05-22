variable "environment" { type = string }
variable "project" { type = string }
variable "github_repo" { type = string }
variable "github_oidc_subjects" {
  type    = list(string)
  default = []
}

data "aws_caller_identity" "current" {}

locals {
  allowed_subjects = length(var.github_oidc_subjects) > 0 ? var.github_oidc_subjects : [
    "repo:${var.github_repo}:ref:refs/heads/main",
    "repo:${var.github_repo}:pull_request",
    "repo:${var.github_repo}:environment:dev"
  ]
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project}-${var.environment}-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = local.allowed_subjects
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_admin" {
  # checkov:skip=CKV_AWS_274:Lab environment requires admin for setup
  # checkov:skip=CKV2_AWS_56:Lab environment requires broad permissions
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}
