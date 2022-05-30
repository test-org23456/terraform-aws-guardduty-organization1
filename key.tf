resource "aws_kms_key" "guardduty" {
  enable_key_rotation = true
  tags = {
    Name = "guardduty"
  }
}

resource "aws_kms_alias" "guardduty" {
  name_prefix   = "alias/guardduty-"
  target_key_id = aws_kms_key.guardduty.key_id
  lifecycle {
    ignore_changes = [name_prefix]
  }
}

