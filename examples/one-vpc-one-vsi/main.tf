##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source         = "terraform-ibm-modules/landing-zone/ibm"
  version        = "8.14.15"
  prefix         = var.prefix
  region         = var.region
  ssh_public_key = var.ssh_key
  override       = true
  tags           = var.resource_tags
}
