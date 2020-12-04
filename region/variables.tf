variable "aws_region" {
  type = string
}

variable "parameters" {
  type = object({
    aws_credentials = object({
      master = object({
        profile         = string
        assume_role_arn = string
      })
      admin = object({
        profile         = string
        assume_role_arn = string
      })
    })
    finding_publishing_frequency = string
    s3                           = any
    lambda                       = any
    filters                      = any
  })
}

