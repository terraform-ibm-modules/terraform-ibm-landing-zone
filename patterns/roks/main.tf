##############################################################################
# Landing Zone
##############################################################################

module "landing_zone" {
  source          = "./module"
  prefix          = var.prefix
  region          = var.region
  tags            = var.tags
  resource_groups = var.resource_groups
  # transit_gateway_resource_group = local.env.transit_gateway_resource_group
  # transit_gateway_connections    = local.env.transit_gateway_connections
  # ssh_keys                       = local.env.ssh_keys
  # vsi                            = local.env.vsi
  # security_groups                = local.env.security_groups
  # virtual_private_endpoints      = local.env.virtual_private_endpoints
  # cos                            = local.env.cos
  # service_endpoints              = local.env.service_endpoints
  # key_management                 = local.env.key_management
  # atracker             = local.env.atracker
  # clusters             = local.env.clusters
  wait_till = var.wait_till
  # iam_account_settings = local.env.iam_account_settings
  # access_groups        = local.env.access_groups
  # f5_vsi               = local.env.f5_vsi
  # f5_template_data     = local.env.f5_template_data
  # appid                = local.env.appid
  # teleport_config_data = local.env.teleport_config
  # teleport_vsi         = local.env.teleport_vsi
  # secrets_manager      = local.env.secrets_manager
  # vpc_placement_groups = local.env.vpc_placement_groups
  # # If enable_scc is true, pass the credential created from the pattern to landing_zone. Credential is created in the pattern since it uses the IBM Cloud API key
  # security_compliance_center = merge(
  #   local.env.security_compliance_center,
  #   { credential_id = var.enable_scc ? ibm_scc_posture_credential.credentials[0].id : null }
  # )
  ibmcloud_api_key = var.ibmcloud_api_key

  network_cidr           = var.network_cidr
  vpcs                   = var.vpcs
  enable_transit_gateway = var.enable_transit_gateway
  ssh_public_key         = var.ssh_public_key

  update_all_workers    = var.update_all_workers
  existing_ssh_key_name = var.existing_ssh_key_name
  entitlement           = var.entitlement
  workers_per_zone      = var.workers_per_zone
  flavor                = var.flavor
  kube_version          = var.kube_version

  add_atracker_route       = var.add_atracker_route
  hs_crypto_instance_name  = var.hs_crypto_instance_name
  hs_crypto_resource_group = var.hs_crypto_resource_group
  use_random_cos_suffix    = var.use_random_cos_suffix

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
  enable_scc                          = var.enable_scc
  scc_cred_description                = var.scc_cred_description
  scc_cred_name                       = var.scc_cred_name
  add_kms_block_storage_s2s           = var.add_kms_block_storage_s2s
}

##############################################################################
