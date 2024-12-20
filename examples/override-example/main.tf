##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source               = "../../patterns/vsi/module"
  prefix               = var.prefix
  region               = var.region
  ssh_public_key       = var.ssh_key
  override             = true
  tags                 = var.resource_tags
  override_json_string = var.override_json_string
}
