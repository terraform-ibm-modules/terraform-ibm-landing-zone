##############################################################################
# QuickStart VSI Landing Zone
##############################################################################

module "landing_zone" {
  source               = "../roks/module"
  prefix               = var.prefix
  region               = var.region
  override_json_string = var.override_json_string
  tags                 = var.resource_tags
}
