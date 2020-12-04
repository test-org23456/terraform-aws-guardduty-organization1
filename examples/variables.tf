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

variable "ipset" {
  type = string
}

variable "threatintelset" {
  type = string
}

variable "filters" {
  default = [
    {
      name = "ConsoleLogin"
      criterions = [
        {
          field  = "region"
          not_equals = ["us-east-1"]
        },
        {
          field  = "type"
          equals = ["UnauthorizedAccess:IAMUser/ConsoleLogin"]
        }
      ]
    }
  ]
}

variable "incoming_web_hook_url" {
  type = string
}

variable "slack_channel" {
  type = string
}

variable "min_severity_level" {
  type = string
}
