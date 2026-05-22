variable "environment" { type = string }
variable "project" { type = string }

data "aws_region" "current" {}

resource "aws_securityhub_account" "primary" {}

resource "aws_securityhub_standards_subscription" "aws_foundational" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.primary]
}
