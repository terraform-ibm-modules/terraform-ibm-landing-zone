##############################################################################
# Service Authorizations
##############################################################################

module "service_authorizations" {
  source                                 = "./config_modules/service_authorizations"
  key_management                         = var.key_management
  key_management_guid                    = var.key_management_guid
  key_management_key_map                 = var.key_management_key_map
  cos                                    = var.cos
  cos_instance_ids                       = local.cos_instance_ids
  skip_kms_block_storage_s2s_auth_policy = var.skip_kms_block_storage_s2s_auth_policy
  skip_all_s2s_auth_policies             = var.skip_all_s2s_auth_policies
  skip_kms_kube_s2s_auth_policy          = var.skip_kms_kube_s2s_auth_policy
  atracker_cos_bucket                    = var.atracker_cos_bucket
  clusters                               = var.clusters
  vsi                                    = var.vsi
  vpcs                                   = var.vpcs
}

##############################################################################
