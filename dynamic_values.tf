##############################################################################
# Create Dynamic Values
##############################################################################

module "dynamic_values" {
  source                    = "./dynamic_values"
  region                    = var.region
  prefix                    = var.prefix
  key_management            = var.key_management
  key_management_guid       = module.key_management.key_management_guid
  clusters                  = var.clusters
  vpcs                      = var.vpcs
  resource_groups           = local.resource_groups
  vpc_modules               = module.vpc
  cos                       = var.cos
  cos_data_source           = data.ibm_resource_instance.cos
  cos_resource              = ibm_resource_instance.cos
  cos_resource_keys         = ibm_resource_key.key
  suffix                    = random_string.random_cos_suffix.result
  ssh_keys                  = var.ssh_keys
  vsi                       = var.vsi
  virtual_private_endpoints = var.virtual_private_endpoints
  vpn_gateways              = var.vpn_gateways
  security_groups           = var.security_groups
  bastion_vsi               = var.teleport_vsi
  access_groups             = var.access_groups
  appid                     = var.appid
  appid_resource            = ibm_resource_instance.appid
  appid_data                = data.ibm_resource_instance.appid
  teleport_domain           = tostring(var.teleport_config_data.domain)
  f5_vsi                    = var.f5_vsi
  f5_template_data          = var.f5_template_data
  secrets_manager           = var.secrets_manager
  add_kms_block_storage_s2s = var.add_kms_block_storage_s2s
  atracker_cos_bucket       = var.atracker.add_route == true ? var.atracker.collector_bucket_name : null
}

##############################################################################
