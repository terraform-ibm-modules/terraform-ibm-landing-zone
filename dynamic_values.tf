##############################################################################
# Create Dynamic Values
##############################################################################

module "dynamic_values" {
  source                                 = "./dynamic_values"
  region                                 = var.region
  prefix                                 = var.prefix
  key_management                         = var.key_management
  key_management_guid                    = module.key_management.key_management_guid
  key_management_key_map                 = module.key_management.key_map
  clusters                               = var.clusters
  vpcs                                   = var.vpcs
  resource_groups                        = local.resource_groups
  vpc_modules                            = module.vpc
  cos                                    = var.cos
  cos_data_source                        = data.ibm_resource_instance.cos
  cos_resource                           = ibm_resource_instance.cos
  cos_resource_keys                      = ibm_resource_key.key
  suffix                                 = random_string.random_cos_suffix.result
  ssh_keys                               = var.ssh_keys
  vsi                                    = var.vsi
  virtual_private_endpoints              = var.virtual_private_endpoints
  vpn_gateways                           = var.vpn_gateways
  security_groups                        = var.security_groups
  bastion_vsi                            = var.teleport_vsi
  appid                                  = var.appid
  appid_resource                         = ibm_resource_instance.appid
  appid_data                             = data.ibm_resource_instance.appid
  teleport_domain                        = tostring(try(var.teleport_config_data.domain, null))
  f5_vsi                                 = var.f5_vsi
  f5_template_data                       = var.f5_template_data
  skip_kms_block_storage_s2s_auth_policy = var.skip_kms_block_storage_s2s_auth_policy
  skip_kms_kube_s2s_auth_policy          = var.skip_kms_kube_s2s_auth_policy
  skip_all_s2s_auth_policies             = var.skip_all_s2s_auth_policies
  atracker_cos_bucket                    = var.atracker.add_route == true ? var.atracker.collector_bucket_name : null
}

##############################################################################
