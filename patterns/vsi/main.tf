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

module "landing_zone_module" {
  source = "./module"
  prefix = var.prefix
  region = var.region
  tags   = var.tags

  network_cidr = var.network_cidr
  # resource_groups                = var.resource_groups
  vpcs                           = var.vpcs
  enable_transit_gateway         = var.enable_transit_gateway
  # vpn_gateways                   = var.vpn_gateways
  # transit_gateway_resource_group = var.transit_gateway_resource_group
  # transit_gateway_connections    = var.transit_gateway_connections
  ssh_public_key                       = var.ssh_public_key
  # vsi                            = var.vsi
  # security_groups                = var.security_groups
  # virtual_private_endpoints      = var.virtual_private_endpoints
  # # cos                            = var.cos
  # service_endpoints              = var.service_endpoints
  # key_management                 = var.key_management
  # add_kms_block_storage_s2s      = var.add_kms_block_storage_s2s
  # atracker                       = var.atracker
  # clusters                       = var.clusters
  # wait_till                      = var.wait_till
  # iam_account_settings           = var.iam_account_settings
  # access_groups                  = var.access_groups
  # f5_vsi                         = var.f5_vsi
  # f5_template_data               = var.f5_template_data
  # appid                          = var.appid
  # teleport_config_data           = var.teleport_config
  # teleport_vsi                   = var.teleport_vsi
  # secrets_manager                = var.secrets_manager
  # vpc_placement_groups           = var.vpc_placement_groups
  # # If enable_scc is true, pass the credential created from the pattern to landing_zone.Credential is created in the pattern since it uses the IBM Cloud API key
  # security_compliance_center = merge(
  #   var.security_compliance_center,
  #   { credential_id = var.enable_scc ? ibm_scc_posture_credential.credentials[0].id : null }
  # )
  ibmcloud_api_key = var.ibmcloud_api_key


  existing_ssh_key_name = var.existing_ssh_key_name

  add_atracker_route                  = var.add_atracker_route
  hs_crypto_instance_name             = var.hs_crypto_instance_name
  hs_crypto_resource_group            = var.hs_crypto_resource_group
  use_random_cos_suffix               = var.use_random_cos_suffix
  vsi_image_name                      = var.vsi_image_name
  vsi_instance_profile                = var.vsi_instance_profile
  vsi_per_subnet                      = var.vsi_per_subnet
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
  # add_kms_block_storage_s2s = var.add_kms_block_storage_s2s
  override              = var.override
  override_json_string  = var.override_json_string
  license_sku_keyword_2 = var.license_sku_keyword_2


}

##############################################################################

##############################################################################
# Security and Compliance Center
##############################################################################

resource "ibm_scc_posture_credential" "credentials" {
  count       = var.enable_scc ? 1 : 0
  description = var.scc_cred_description
  display_fields {
    ibm_api_key = var.ibmcloud_api_key
  }
  enabled = true
  name    = var.scc_cred_name
  purpose = "discovery_fact_collection_remediation"
  type    = "ibm_cloud"
}

##############################################################################
