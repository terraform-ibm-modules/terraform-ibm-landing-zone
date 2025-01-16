##############################################################################
# QuickStart VSI Landing Zone
##############################################################################

module "landing_zone" {
  source               = "../vsi/module"
  prefix               = var.prefix
  region               = var.region
  ssh_public_key       = var.ssh_key
  override_json_string = var.override_json_string
  user_data            = var.user_data
  tags                 = var.resource_tags
}
