##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source  = "terraform-ibm-modules/landing-zone/ibm//patterns//vpc//module"
  version = "5.2.0"
  region  = var.region
  prefix  = var.prefix
  tags    = var.resource_tags
}
