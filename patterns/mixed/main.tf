##############################################################################
# IBM Cloud Provider
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 60
}

##############################################################################


##############################################################################
# Landing Zone
##############################################################################

module "landing_zone" {
  source                                 = "../../"
  ibmcloud_api_key                       = var.ibmcloud_api_key
  prefix                                 = var.prefix
  region                                 = var.region
  tags                                   = var.tags
  resource_groups                        = local.env.resource_groups
  network_cidr                           = local.env.network_cidr
  vpcs                                   = local.env.vpcs
  vpn_gateways                           = local.env.vpn_gateways
  enable_transit_gateway                 = local.env.enable_transit_gateway
  transit_gateway_global                 = local.env.transit_gateway_global
  transit_gateway_resource_group         = local.env.transit_gateway_resource_group
  transit_gateway_connections            = local.env.transit_gateway_connections
  ssh_keys                               = local.env.ssh_keys
  vsi                                    = local.env.vsi
  security_groups                        = local.env.security_groups
  virtual_private_endpoints              = local.env.virtual_private_endpoints
  cos                                    = local.env.cos
  service_endpoints                      = local.env.service_endpoints
  key_management                         = local.env.key_management
  skip_kms_block_storage_s2s_auth_policy = local.env.skip_kms_block_storage_s2s_auth_policy
  skip_all_s2s_auth_policies             = local.env.skip_all_s2s_auth_policies
  atracker                               = local.env.atracker
  clusters                               = local.env.clusters
  wait_till                              = local.env.wait_till
  f5_vsi                                 = local.env.f5_vsi
  f5_template_data                       = local.env.f5_template_data
  appid                                  = local.env.appid
  teleport_config_data                   = local.env.teleport_config
  teleport_vsi                           = local.env.teleport_vsi
  vpc_placement_groups                   = local.env.vpc_placement_groups
}

##############################################################################
