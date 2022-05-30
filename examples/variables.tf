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

