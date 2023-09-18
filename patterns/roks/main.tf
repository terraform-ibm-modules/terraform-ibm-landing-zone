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
  source                              = "./module"
  prefix                              = var.prefix
  region                              = var.region
  tags                                = var.tags
  wait_till                           = var.wait_till
  network_cidr                        = var.network_cidr
  vpcs                                = var.vpcs
  enable_transit_gateway              = var.enable_transit_gateway
  transit_gateway_global              = var.transit_gateway_global
  ssh_public_key                      = var.ssh_public_key
  update_all_workers                  = var.update_all_workers
  existing_ssh_key_name               = var.existing_ssh_key_name
  entitlement                         = var.entitlement
  workers_per_zone                    = var.workers_per_zone
  flavor                              = var.flavor
  kube_version                        = var.kube_version
  add_atracker_route                  = var.add_atracker_route
  hs_crypto_instance_name             = var.hs_crypto_instance_name
  hs_crypto_resource_group            = var.hs_crypto_resource_group
  use_random_cos_suffix               = var.use_random_cos_suffix
  add_edge_vpc                        = var.add_edge_vpc
  create_f5_network_on_management_vpc = var.create_f5_network_on_management_vpc
  provision_teleport_in_f5            = var.provision_teleport_in_f5
  f5_instance_profile                 = var.f5_instance_profile
  hostname                            = var.hostname
  domain                              = var.domain
  byol_license_basekey                = var.byol_license_basekey
  license_host                        = var.license_host
  license_username                    = var.license_username
  license_password                    = var.license_password
  license_pool                        = var.license_pool
  license_sku_keyword_1               = var.license_sku_keyword_1
  license_sku_keyword_2               = var.license_sku_keyword_2
  license_unit_of_measure             = var.license_unit_of_measure
  do_declaration_url                  = var.do_declaration_url
  as3_declaration_url                 = var.as3_declaration_url
  ts_declaration_url                  = var.ts_declaration_url
  phone_home_url                      = var.phone_home_url
  template_source                     = var.template_source
  template_version                    = var.template_version
  app_id                              = var.app_id
  tgactive_url                        = var.tgactive_url
  tgstandby_url                       = var.tgstandby_url
  tgrefresh_url                       = var.tgrefresh_url
  enable_f5_management_fip            = var.enable_f5_management_fip
  enable_f5_external_fip              = var.enable_f5_external_fip
  use_existing_appid                  = var.use_existing_appid
  appid_name                          = var.appid_name
  appid_resource_group                = var.appid_resource_group
  teleport_instance_profile           = var.teleport_instance_profile
  teleport_vsi_image_name             = var.teleport_vsi_image_name
  teleport_license                    = var.teleport_license
  https_cert                          = var.https_cert
  https_key                           = var.https_key
  teleport_hostname                   = var.teleport_hostname
  teleport_domain                     = var.teleport_domain
  teleport_version                    = var.teleport_version
  message_of_the_day                  = var.message_of_the_day
  teleport_admin_email                = var.teleport_admin_email
  create_secrets_manager              = var.create_secrets_manager
  override                            = var.override
  override_json_string                = var.override_json_string
  override_json_path                  = local.override_json_path
  add_kms_block_storage_s2s           = var.add_kms_block_storage_s2s
  cluster_zones                       = var.cluster_zones
  vpn_firewall_type                   = var.vpn_firewall_type
  f5_image_name                       = var.f5_image_name
  tmos_admin_password                 = var.tmos_admin_password
  license_type                        = var.license_type
  teleport_management_zones           = var.teleport_management_zones
  IC_SCHEMATICS_WORKSPACE_ID          = var.IC_SCHEMATICS_WORKSPACE_ID
}

moved {
  from = module.landing_zone
  to   = module.roks_landing_zone.module.landing_zone
}

##############################################################################
