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

resource "aws_s3_bucket" "guardduty" {
  bucket_prefix = "aws-guardduty-"
}

resource "aws_s3_bucket_acl" "guardduty" {
  bucket = aws_s3_bucket.guardduty.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "guardduty" {
  bucket                  = aws_s3_bucket.guardduty.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "guardduty" {
  bucket = aws_s3_bucket.guardduty.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.guardduty.arn
      sse_algorithm     = "aws:kms"
    }
  }
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
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.admin.account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.guardduty.arn}/*"]
  }
}

resource "aws_s3_object" "ipset" {
  bucket  = aws_s3_bucket.guardduty.id
  acl     = "private"
  content = var.parameters.ipset
  key     = "ipset.txt"
}

resource "aws_s3_object" "threatintelset" {
  bucket  = aws_s3_bucket.guardduty.id
  acl     = "private"
  content = var.parameters.threatintelset
  key     = "threatintelset.txt"
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
    effect  = "Allow"
    actions = ["kms:Decrypt*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.admin.account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_alias" "guardduty" {
  name          = "alias/guardduty/s3"
  target_key_id = aws_kms_key.guardduty.key_id
}

