variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "parameters" {
  type = object({
    aws_credentials = object({
      admin = object({
        profile         = string
        assume_role_arn = string
      })
    })
    slack_channel      = string
    min_severity_level = string
    default_tags       = map(any)
  })
}

