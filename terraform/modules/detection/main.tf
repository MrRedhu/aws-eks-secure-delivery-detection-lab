variable "environment" { type = string }
variable "project" { type = string }
variable "alert_email" { type = string }
variable "cluster_name" { type = string }

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_guardduty_detector" "primary" {
  # checkov:skip=CKV2_AWS_3:Organization/Region specific GuardDuty not required for single account lab
  enable = true
}

resource "aws_guardduty_detector_feature" "eks_runtime" {
  detector_id = aws_guardduty_detector.primary.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"
}

# checkov:skip=CKV_AWS_119:Allow SecurityHub to be managed manually if Config is not setup
resource "aws_securityhub_account" "primary" {}

resource "aws_sns_topic" "alerts" {
  name = "${var.project}-${var.environment}-security-alerts"
  # checkov:skip=CKV_AWS_26:Encryption not required for lab notifications
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project}-${var.environment}-router-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_sns" {
  name = "sns-publish"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sns:Publish"
      Effect   = "Allow"
      Resource = aws_sns_topic.alerts.arn
    }]
  })
}

data "archive_file" "router_zip" {
  type        = "zip"
  source_file = "${path.module}/src/router.py"
  output_path = "${path.module}/router.zip"
}

resource "aws_lambda_function" "router" {
  filename         = data.archive_file.router_zip.output_path
  function_name    = "${var.project}-${var.environment}-gd-router"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "router.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.router_zip.output_base64sha256

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }

  # checkov:skip=CKV_AWS_116:DLQ not needed for lab
  # checkov:skip=CKV_AWS_272:Code signing not needed for lab
  # checkov:skip=CKV_AWS_173:KMS encryption of env vars not needed for lab
  # checkov:skip=CKV_AWS_117:VPC attachment not needed for lab
  # checkov:skip=CKV_AWS_115:Concurrency limit not needed for lab
  # checkov:skip=CKV_AWS_50:X-Ray tracing not needed for lab
}

resource "aws_cloudwatch_event_rule" "gd_findings" {
  name        = "${var.project}-${var.environment}-gd-high"
  description = "Capture high severity GuardDuty findings"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", 7] }]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.gd_findings.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.router.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.router.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.gd_findings.arn
}
