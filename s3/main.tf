provider "aws" {
  region  = var.aws_region
  profile = var.parameters.aws_credentials.admin.profile
  assume_role {
    role_arn = var.parameters.aws_credentials.admin.assume_role_arn
  }
}

data "aws_organizations_organization" "admin" {}

resource "aws_s3_bucket" "guardduty" {
  bucket_prefix = "aws-guardduty-"
  acl           = "private"
}

resource "aws_s3_bucket_public_access_block" "guardduty" {
  bucket                  = aws_s3_bucket.guardduty.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "guardduty" {
  bucket     = aws_s3_bucket.guardduty.id
  policy     = data.aws_iam_policy_document.guardduty.json
  depends_on = [aws_s3_bucket_public_access_block.guardduty]
}

data "aws_iam_policy_document" "guardduty" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.guardduty.arn}/*"]
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [data.aws_organizations_organization.admin.id]
    }
  }
}

resource "aws_s3_bucket_object" "ipset" {
  bucket  = aws_s3_bucket.guardduty.id
  acl     = "private"
  content = var.parameters.ipset
  key     = "ipset.txt"
}

resource "aws_s3_bucket_object" "threatintelset" {
  bucket  = aws_s3_bucket.guardduty.id
  acl     = "private"
  content = var.parameters.threatintelset
  key     = "threatintelset.txt"
}

