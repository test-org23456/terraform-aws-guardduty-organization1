variable "admin_profile" {
  type    = string
  default = null
}

variable "master_profile" {
  type    = string
  default = null
}

variable "admin_assume_role_arn" {
  type    = string
  default = null
}

variable "master_assume_role_arn" {
  type    = string
  default = null
}

variable "finding_publishing_frequency" {
  type    = string
  default = "FIFTEEN_MINUTES"
}

variable "ipset" {
  type    = string
  default = ""
}

variable "threatintelset" {
  type    = string
  default = ""
}

variable "filters" {
  type    = any
  default = []
}

variable "lambda_aws_region" {
  type    = string
  default = "us-east-1"
}

variable "slack_channel" {
  type        = string
  description = "The slack channel to send findings to"
  default     = "#general"
}

variable "min_severity_level" {
  type        = string
  description = "The minimum findings severity to send to your slack channel (LOW, MEDIUM or HIGH)"
  default     = "LOW"
}

variable "default_tags" {
  type    = map(any)
  default = null
}

