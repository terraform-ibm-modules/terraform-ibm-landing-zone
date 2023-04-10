##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source                 = "../../patterns/standard"
  prefix                 = var.prefix
  region                 = var.region
  ibmcloud_api_key       = var.ibmcloud_api_key
  tags                   = var.resource_tags
  network_cidr           = var.network_cidr
  vpcs                   = var.vpcs
  enable_transit_gateway = var.enable_transit_gateway
  add_atracker_route     = var.add_atracker_route
}
