locals {
  aws_credentials_admin = {
    profile         = var.admin_profile
    assume_role_arn = var.admin_assume_role_arn
  }
  aws_credentials_master = {
    profile         = var.master_profile
    assume_role_arn = var.master_assume_role_arn
  }
}

module "s3" {
  source = "./s3"
  parameters = {
    aws_credentials = {
      admin = local.aws_credentials_admin
    }
    ipset          = var.ipset
    threatintelset = var.threatintelset
  }
}

module "lambda" {
  source = "./lambda"
  parameters = {
    aws_credentials = {
      admin = local.aws_credentials_admin
    }
    incoming_web_hook_url = var.incoming_web_hook_url
    slack_channel         = var.slack_channel
    min_severity_level    = var.min_severity_level
  }
}

locals {
  parameters = {
    aws_credentials = {
      admin  = local.aws_credentials_admin
      master = local.aws_credentials_master
    }
    finding_publishing_frequency = var.finding_publishing_frequency
    s3                           = module.s3
    lambda                       = module.lambda
  }
}

