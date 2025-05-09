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

locals {
  override_json_path = abspath("./override.json")
}

module "roks_landing_zone" {
  source                                 = "./module"
  prefix                                 = var.prefix
  region                                 = var.region
  tags                                   = var.tags
  wait_till                              = var.wait_till
  network_cidr                           = var.network_cidr
  vpcs                                   = var.vpcs
  ignore_vpcs_for_cluster_deployment     = var.ignore_vpcs_for_cluster_deployment
  enable_transit_gateway                 = var.enable_transit_gateway
  transit_gateway_global                 = var.transit_gateway_global
  ssh_public_key                         = var.ssh_public_key
  existing_ssh_key_name                  = var.existing_ssh_key_name
  entitlement                            = var.entitlement
  secondary_storage                      = var.secondary_storage
  workers_per_zone                       = var.workers_per_zone
  flavor                                 = var.flavor
  kube_version                           = var.kube_version
  cluster_addons                         = var.cluster_addons
  manage_all_cluster_addons              = var.manage_all_cluster_addons
  add_atracker_route                     = var.add_atracker_route
  hs_crypto_instance_name                = var.hs_crypto_instance_name
  hs_crypto_resource_group               = var.hs_crypto_resource_group
  existing_kms_instance_name             = var.existing_kms_instance_name
  existing_kms_resource_group            = var.existing_kms_resource_group
  existing_kms_endpoint_type             = var.existing_kms_endpoint_type
  existing_cos_instance_name             = var.existing_cos_instance_name
  existing_cos_resource_group            = var.existing_cos_resource_group
  existing_cos_endpoint_type             = var.existing_cos_endpoint_type
  use_existing_cos_for_atracker          = var.use_existing_cos_for_atracker
  use_existing_cos_for_vpc_flowlogs      = var.use_existing_cos_for_vpc_flowlogs
  use_random_cos_suffix                  = var.use_random_cos_suffix
  add_edge_vpc                           = var.add_edge_vpc
  create_f5_network_on_management_vpc    = var.create_f5_network_on_management_vpc
  provision_teleport_in_f5               = var.provision_teleport_in_f5
  f5_instance_profile                    = var.f5_instance_profile
  hostname                               = var.hostname
  domain                                 = var.domain
  byol_license_basekey                   = var.byol_license_basekey
  license_host                           = var.license_host
  license_username                       = var.license_username
  disable_outbound_traffic_protection    = var.disable_outbound_traffic_protection
  cluster_force_delete_storage           = var.cluster_force_delete_storage
  operating_system                       = var.operating_system
  license_password                       = var.license_password
  license_pool                           = var.license_pool
  license_sku_keyword_1                  = var.license_sku_keyword_1
  license_sku_keyword_2                  = var.license_sku_keyword_2
  license_unit_of_measure                = var.license_unit_of_measure
  do_declaration_url                     = var.do_declaration_url
  as3_declaration_url                    = var.as3_declaration_url
  ts_declaration_url                     = var.ts_declaration_url
  phone_home_url                         = var.phone_home_url
  template_source                        = var.template_source
  template_version                       = var.template_version
  app_id                                 = var.app_id
  tgactive_url                           = var.tgactive_url
  tgstandby_url                          = var.tgstandby_url
  tgrefresh_url                          = var.tgrefresh_url
  enable_f5_management_fip               = var.enable_f5_management_fip
  enable_f5_external_fip                 = var.enable_f5_external_fip
  use_existing_appid                     = var.use_existing_appid
  appid_name                             = var.appid_name
  appid_resource_group                   = var.appid_resource_group
  teleport_instance_profile              = var.teleport_instance_profile
  teleport_vsi_image_name                = var.teleport_vsi_image_name
  teleport_license                       = var.teleport_license
  https_cert                             = var.https_cert
  https_key                              = var.https_key
  teleport_hostname                      = var.teleport_hostname
  teleport_domain                        = var.teleport_domain
  teleport_version                       = var.teleport_version
  message_of_the_day                     = var.message_of_the_day
  teleport_admin_email                   = var.teleport_admin_email
  override                               = var.override
  override_json_string                   = var.override_json_string
  override_json_path                     = local.override_json_path
  skip_kms_block_storage_s2s_auth_policy = var.skip_kms_block_storage_s2s_auth_policy
  skip_all_s2s_auth_policies             = var.skip_all_s2s_auth_policies
  cluster_zones                          = var.cluster_zones
  vpn_firewall_type                      = var.vpn_firewall_type
  f5_image_name                          = var.f5_image_name
  tmos_admin_password                    = var.tmos_admin_password
  license_type                           = var.license_type
  teleport_management_zones              = var.teleport_management_zones
  IC_SCHEMATICS_WORKSPACE_ID             = var.IC_SCHEMATICS_WORKSPACE_ID
  kms_wait_for_apply                     = var.kms_wait_for_apply
  verify_cluster_network_readiness       = var.verify_cluster_network_readiness
  use_ibm_cloud_private_api_endpoints    = var.use_ibm_cloud_private_api_endpoints
  existing_vpc_cbr_zone_id               = var.existing_vpc_cbr_zone_id
}

moved {
  from = module.landing_zone
  to   = module.roks_landing_zone.module.landing_zone
}

##############################################################################
