##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source           = "../../../patterns/roks"
  prefix           = var.prefix
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  override         = true
  tags             = var.resource_tags
}
