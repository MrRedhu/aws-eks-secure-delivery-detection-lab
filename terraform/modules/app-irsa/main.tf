variable "environment" { type = string }
variable "project" { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_provider" { type = string }
variable "namespace" { type = string }
variable "service_account_name" { type = string }

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.project}-${var.environment}-secure-demo-irsa"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "IRSA role for the secure demo API service account."
}

output "role_arn" {
  value = aws_iam_role.app.arn
}
