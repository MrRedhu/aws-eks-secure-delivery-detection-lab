variable "environment" { type = string }
variable "project" { type = string }

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  trail_name  = "${var.project}-${var.environment}-management"
  bucket_name = "eks-sec-delivery-${var.environment}-trail-${data.aws_caller_identity.current.account_id}"
  trail_arn   = "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.trail_name}"
}

data "aws_iam_policy_document" "trail_kms" {
  statement {
    sid     = "EnableAccountAdministration"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid = "AllowCloudTrailUse"
    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
    resources = ["*"]
  }

  statement {
    sid = "AllowSNSUse"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "trail" {
  description         = "KMS key for CloudTrail and CloudTrail log group"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.trail_kms.json
}

resource "aws_kms_alias" "trail" {
  name          = "alias/${var.project}-${var.environment}-cloudtrail"
  target_key_id = aws_kms_key.trail.key_id
}

resource "aws_s3_bucket" "trail" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "trail" {
  bucket                  = aws_s3_bucket.trail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.trail.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "trail" {
  bucket = aws_s3_bucket.trail.id

  rule {
    id     = "expire-cloudtrail-logs"
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

resource "aws_s3_bucket_versioning" "trail" {
  bucket = aws_s3_bucket.trail.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "trail_bucket" {
  statement {
    sid = "AWSCloudTrailAclCheck"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.trail.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid = "AWSCloudTrailWrite"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.trail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail.id
  policy = data.aws_iam_policy_document.trail_bucket.json
}

resource "aws_sns_topic" "trail" {
  name              = "${var.project}-${var.environment}-cloudtrail"
  kms_master_key_id = aws_kms_key.trail.arn
}

data "aws_iam_policy_document" "trail_topic" {
  statement {
    sid = "AllowCloudTrailPublish"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.trail.arn]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }
}

resource "aws_sns_topic_policy" "trail" {
  arn    = aws_sns_topic.trail.arn
  policy = data.aws_iam_policy_document.trail_topic.json
}

resource "aws_cloudwatch_log_group" "trail" {
  name              = "/aws/cloudtrail/${local.trail_name}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.trail.arn
}

data "aws_iam_policy_document" "trail_logs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "trail_logs" {
  name               = "${var.project}-${var.environment}-cloudtrail-logs"
  assume_role_policy = data.aws_iam_policy_document.trail_logs_assume.json
}

resource "aws_iam_role_policy" "trail_logs" {
  name = "cloudwatch-logs"
  role = aws_iam_role.trail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.trail.arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "management" {
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.trail.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.trail.arn
  sns_topic_name                = aws_sns_topic.trail.name
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.trail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.trail_logs.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [
    aws_iam_role_policy.trail_logs,
    aws_s3_bucket_policy.trail,
    aws_sns_topic_policy.trail
  ]
}
