variable "environment" { type = string }
variable "project" { type = string }

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "eks_secrets" {
  # checkov:skip=CKV2_AWS_64:Using default AWS KMS policy for lab
  description             = "EKS Secret Encryption Key for ${var.project}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.project}-${var.environment}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

output "key_arn" {
  value = aws_kms_key.eks_secrets.arn
}
