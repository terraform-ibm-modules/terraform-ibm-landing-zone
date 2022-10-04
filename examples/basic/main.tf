##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source                   = "../../patterns/vsi"
  prefix                   = var.prefix
  region                   = var.region
  tags                     = var.resource_tags
  ibmcloud_api_key         = var.ibmcloud_api_key
  ssh_public_key           = var.ssh_key
  network_cidr             = var.network_cidr
  vpcs                     = var.vpcs
  enable_transit_gateway   = var.enable_transit_gateway
  add_atracker_route       = var.add_atracker_route
  hs_crypto_instance_name  = var.hs_crypto_instance_name
  hs_crypto_resource_group = var.hs_crypto_resource_group
  vsi_image_name           = var.vsi_image_name
  vsi_instance_profile     = var.vsi_instance_profile
  vsi_per_subnet           = var.vsi_per_subnet
  use_random_cos_suffix    = var.use_random_cos_suffix
}
