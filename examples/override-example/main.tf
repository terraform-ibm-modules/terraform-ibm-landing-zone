##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source           = "../../patterns/vsi/module"
  ibmcloud_api_key = var.ibmcloud_api_key
  prefix           = var.prefix
  region           = var.region
  ssh_public_key   = var.ssh_key
  override         = true
  tags             = var.resource_tags
}
