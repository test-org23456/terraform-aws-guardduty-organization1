provider "aws" {
  alias   = "master"
  region  = var.aws_region
  profile = var.parameters.aws_credentials.master.profile
  assume_role {
    role_arn = var.parameters.aws_credentials.master.assume_role_arn
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.parameters.aws_credentials.admin.profile
  assume_role {
    role_arn = var.parameters.aws_credentials.admin.assume_role_arn
  }
}

provider "aws" {
  alias   = "lambda"
  region  = local.lambda == null ? "us-east-1" : local.lambda.aws_region
  profile = var.parameters.aws_credentials.admin.profile
  assume_role {
    role_arn = var.parameters.aws_credentials.admin.assume_role_arn
  }
}

data "aws_caller_identity" "admin" {}

locals {
  admin_account_id             = data.aws_caller_identity.admin.account_id
  finding_publishing_frequency = var.parameters.finding_publishing_frequency
  s3                           = var.parameters.s3
  lambda                       = var.parameters.lambda
}

resource "aws_guardduty_detector" "master" {
  provider                     = aws.master
  enable                       = true
  finding_publishing_frequency = local.finding_publishing_frequency
}

resource "aws_guardduty_detector" "admin" {
  enable                       = true
  finding_publishing_frequency = local.finding_publishing_frequency
}

resource "aws_guardduty_ipset" "admin" {
  count       = local.s3 == null ? 0 : 1
  detector_id = aws_guardduty_detector.admin.id
  name        = "ipset"
  format      = "TXT"
  location    = local.s3.ipset_location
  activate    = true
}

resource "aws_guardduty_threatintelset" "admin" {
  count       = local.s3 == null ? 0 : 1
  detector_id = aws_guardduty_detector.admin.id
  name        = "threatintelset"
  format      = "TXT"
  location    = local.s3.threatintelset_location
  activate    = true
}

resource "aws_cloudwatch_event_rule" "guardduty" {
  name = "guardduty"
  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "guardduty" {
  target_id = "guardduty"
  rule      = aws_cloudwatch_event_rule.guardduty.name
  arn       = aws_sns_topic.guardduty.arn
}

resource "aws_sns_topic" "guardduty" {
  name = "guardduty"
}

resource "aws_sns_topic_policy" "guardduty" {
  arn    = aws_sns_topic.guardduty.arn
  policy = data.aws_iam_policy_document.guardduty.json
}

data "aws_iam_policy_document" "guardduty" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [aws_sns_topic.guardduty.arn]
  }
}

resource "aws_sns_topic_subscription" "guardduty" {
  count     = local.lambda == null ? 0 : 1
  topic_arn = aws_sns_topic.guardduty.arn
  protocol  = "lambda"
  endpoint  = local.lambda.function.arn
}

resource "aws_lambda_permission" "guardduty" {
  provider      = aws.lambda
  count         = local.lambda == null ? 0 : 1
  action        = "lambda:InvokeFunction"
  function_name = local.lambda.function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.guardduty.arn
}

resource "aws_guardduty_organization_admin_account" "master" {
  provider         = aws.master
  depends_on       = [aws_guardduty_detector.admin]
  admin_account_id = local.admin_account_id
}

resource "aws_guardduty_organization_configuration" "admin" {
  depends_on  = [aws_guardduty_organization_admin_account.master]
  detector_id = aws_guardduty_detector.admin.id
  auto_enable = true
}

data "aws_organizations_organization" "master" {
  provider = aws.master
}

locals {
  accounts = {
    for a in data.aws_organizations_organization.master.accounts :
    a.id => a.email if a.id != local.admin_account_id && a.status == "ACTIVE"
  }
}

resource "aws_guardduty_member" "admin" {
  depends_on = [
    aws_guardduty_detector.master,
    aws_guardduty_organization_configuration.admin,
  ]
  for_each                   = local.accounts
  detector_id                = aws_guardduty_detector.admin.id
  account_id                 = each.key
  email                      = each.value
  invite                     = false
  disable_email_notification = true
  lifecycle {
    ignore_changes = [
      email,
      invite,
    ]
  }
}

