variable "environment" { type = string }
variable "project" { type = string }

data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

locals {
  bucket_name = "eks-sec-delivery-${var.environment}-config-${data.aws_caller_identity.current.account_id}"
}

resource "aws_kms_key" "config" {
  description         = "KMS key for AWS Config delivery bucket"
  enable_key_rotation = true
}

resource "aws_kms_alias" "config" {
  name          = "alias/${var.project}-${var.environment}-aws-config"
  target_key_id = aws_kms_key.config.key_id
}

resource "aws_s3_bucket" "config" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket                  = aws_s3_bucket.config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.config.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    id     = "expire-config-history"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "config" {
  name               = "${var.project}-${var.environment}-aws-config"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config_delivery" {
  name = "config-delivery"
  role = aws_iam_role.config.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.config.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/Config/*"
        Condition = {
          StringLike = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.config.arn
      }
    ]
  })
}

resource "aws_config_configuration_recorder" "primary" {
  name     = "${var.project}-${var.environment}"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "primary" {
  name           = "${var.project}-${var.environment}"
  s3_bucket_name = aws_s3_bucket.config.bucket

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "primary" {
  name       = aws_config_configuration_recorder.primary.name
  is_enabled = true
  depends_on = [
    aws_config_delivery_channel.primary,
    aws_iam_role_policy.config_delivery,
    aws_iam_role_policy_attachment.config
  ]
}
