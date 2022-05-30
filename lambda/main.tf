provider "aws" {
  region  = var.aws_region
  profile = var.parameters.aws_credentials.admin.profile
  assume_role {
    role_arn = var.parameters.aws_credentials.admin.assume_role_arn
  }
  default_tags {
    tags = var.parameters.default_tags
  }
}

data "aws_caller_identity" "admin" {}

locals {
  function_name = "guardduty-to-slack"
}

resource "aws_lambda_function" "guardduty_to_slack" {
  filename         = data.archive_file.guardduty_to_slack.output_path
  function_name    = local.function_name
  description      = "Lambda to push GuardDuty findings to Slack"
  role             = aws_iam_role.guardduty_to_slack.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = "10"
  source_code_hash = data.archive_file.guardduty_to_slack.output_base64sha256
  environment {
    variables = {
      secretId         = aws_secretsmanager_secret.guardduty.id
      slackChannel     = var.parameters.slack_channel
      minSeverityLevel = var.parameters.min_severity_level
    }
  }
  tracing_config {
    mode = "Active"
  }
}

data "archive_file" "guardduty_to_slack" {
  type        = "zip"
  source_file = "${path.module}/gd2slack/index.js"
  output_path = "${path.module}/gd2slack.zip"
}

resource "aws_iam_role" "guardduty_to_slack" {
  name               = "LambdaRoleGuardDutyToSlack"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.guardduty_to_slack.json
}

data "aws_iam_policy_document" "guardduty_to_slack" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

locals {
  guardduty_to_slack_policy_arns = [
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]
}

resource "aws_iam_role_policy_attachment" "guardduty_to_slack" {
  count      = length(local.guardduty_to_slack_policy_arns)
  role       = aws_iam_role.guardduty_to_slack.name
  policy_arn = local.guardduty_to_slack_policy_arns[count.index]
}

resource "aws_iam_role_policy_attachment" "guardduty_to_slack_kms" {
  role       = aws_iam_role.guardduty_to_slack.name
  policy_arn = aws_iam_policy.guardduty_to_slack_kms.arn
}

resource "aws_iam_policy" "guardduty_to_slack_kms" {
  name   = "GuardDutyToSlackLambdaKms"
  path   = "/"
  policy = data.aws_iam_policy_document.guardduty_to_slack_kms.json
}

data "aws_iam_policy_document" "guardduty_to_slack_kms" {
  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.guardduty.arn]
  }
}

resource "aws_cloudwatch_log_group" "guardduty_to_slack" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14
  kms_key_id        = aws_kms_key.guardduty.arn
}

resource "aws_iam_role_policy_attachment" "guardduty_to_slack_log" {
  role       = aws_iam_role.guardduty_to_slack.name
  policy_arn = aws_iam_policy.guardduty_to_slack_log.arn
}

resource "aws_iam_policy" "guardduty_to_slack_log" {
  name   = "GuardDutyToSlackLambdaLogging"
  path   = "/"
  policy = data.aws_iam_policy_document.guardduty_to_slack_log.json
}

data "aws_iam_policy_document" "guardduty_to_slack_log" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.admin.account_id}:log-group:${aws_cloudwatch_log_group.guardduty_to_slack.name}:*"]
  }
}

locals {
  example_secret = {
    slack_webhook_url = "https://hooks.slack.com/services/XXXXXX/YYYYY/REPLACE_WITH_YOURS"
  }
}

resource "aws_secretsmanager_secret" "guardduty" {
  name       = "guardduty"
  kms_key_id = aws_kms_key.guardduty.arn
}

resource "aws_secretsmanager_secret_version" "guardduty" {
  secret_id     = aws_secretsmanager_secret.guardduty.id
  secret_string = jsonencode(local.example_secret)
  lifecycle {
    ignore_changes = [
      secret_string,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "guardduty_to_slack_secret" {
  role       = aws_iam_role.guardduty_to_slack.name
  policy_arn = aws_iam_policy.guardduty_to_slack_secret.arn
}

resource "aws_iam_policy" "guardduty_to_slack_secret" {
  name   = "GuardDutyToSlackLambdaSecret"
  path   = "/"
  policy = data.aws_iam_policy_document.guardduty_to_slack_secret.json
}

data "aws_iam_policy_document" "guardduty_to_slack_secret" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.guardduty.arn]
  }
}

resource "aws_kms_key" "guardduty" {
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.key.json
}

data "aws_iam_policy_document" "key" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.admin.account_id}:root"]
    }
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.admin.account_id}:log-group:/aws/lambda/${local.function_name}"]
    }
  }
}

resource "aws_kms_alias" "guardduty" {
  name          = "alias/guardduty/lambda"
  target_key_id = aws_kms_key.guardduty.key_id
}

