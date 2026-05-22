variable "region" { default = "us-east-1" }
variable "environment" { default = "dev" }
variable "project" { default = "aws-eks-secure-delivery-detection-lab" }
variable "github_repo" { default = "MrRedhu/aws-eks-secure-delivery-detection-lab" }

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Owner       = "Aryan"
      ManagedBy   = "terraform"
      TTL         = "manual-destroy"
      CostCenter  = "portfolio-lab"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  state_bucket_name = "eks-sec-delivery-${var.environment}-tfstate-${data.aws_caller_identity.current.account_id}"
  lock_table_name   = "${var.project}-${var.environment}-tf-locks"
}

resource "aws_kms_key" "bootstrap" {
  description         = "KMS key for ${var.project} ${var.environment} Terraform bootstrap resources"
  enable_key_rotation = true
}

resource "aws_kms_alias" "bootstrap" {
  name          = "alias/${var.project}-${var.environment}-bootstrap"
  target_key_id = aws_kms_key.bootstrap.key_id
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.state_bucket_name
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bootstrap.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "retain-recent-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.bootstrap.arn
  }
}

module "iam" {
  source      = "../modules/iam"
  environment = var.environment
  project     = var.project
  github_repo = var.github_repo
}

output "state_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_locks.name
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}

output "backend_config" {
  value = <<EOT
bucket         = "${aws_s3_bucket.tfstate.bucket}"
key            = "${var.environment}/terraform.tfstate"
region         = "${var.region}"
dynamodb_table = "${aws_dynamodb_table.tf_locks.name}"
encrypt        = true
EOT
}
