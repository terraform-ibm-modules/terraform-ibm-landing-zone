##############################################################################
# SLZ VPC
##############################################################################

module "landing_zone" {
  source                 = "../../../patterns/vpc/module"
  region                 = var.region
  prefix                 = var.prefix
  tags                   = var.resource_tags
  enable_transit_gateway = false
  add_atracker_route     = false
  ibmcloud_api_key       = var.ibmcloud_api_key
}
