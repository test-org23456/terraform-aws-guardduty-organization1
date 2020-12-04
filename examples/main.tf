module "guardduty" {
  source                 = "github.com/asannou/terraform-aws-guardduty-organization"
  admin_profile          = var.admin_profile
  admin_assume_role_arn  = var.admin_assume_role_arn
  master_profile         = var.master_profile
  master_assume_role_arn = var.master_assume_role_arn
  ipset                  = var.ipset
  threatintelset         = var.threatintelset
  filters                = var.filters
}

