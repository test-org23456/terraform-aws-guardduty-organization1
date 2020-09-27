provider "aws" {
  region  = var.aws_region
  profile = var.parameters.aws_credentials.admin.profile
  assume_role {
    role_arn = var.parameters.aws_credentials.admin.assume_role_arn
  }
}

data "aws_caller_identity" "identity" {}

resource "aws_lambda_function" "guardduty_to_slack" {
  filename         = data.archive_file.guardduty_to_slack.output_path
  function_name    = "guardduty-to-slack"
  description      = "Lambda to push GuardDuty findings to Slack"
  role             = aws_iam_role.guardduty_to_slack.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  timeout          = "10"
  source_code_hash = data.archive_file.guardduty_to_slack.output_base64sha256
  environment {
    variables = {
      webHookUrl       = var.parameters.incoming_web_hook_url
      slackChannel     = var.parameters.slack_channel
      minSeverityLevel = var.parameters.min_severity_level
    }
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

resource "aws_cloudwatch_log_group" "guardduty_to_slack" {
  name              = "/aws/lambda/${aws_lambda_function.guardduty_to_slack.function_name}"
  retention_in_days = 14
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
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.identity.account_id}:log-group:${aws_cloudwatch_log_group.guardduty_to_slack.name}:*"]
  }
}

