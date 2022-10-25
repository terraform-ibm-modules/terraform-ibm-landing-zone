##############################################################################
# Service Authorizations
##############################################################################

module "service_authorizations" {
  source                    = "./config_modules/service_authorizations"
  key_management            = var.key_management
  key_management_guid       = var.key_management_guid
  cos                       = var.cos
  cos_instance_ids          = local.cos_instance_ids
  use_secrets_manager       = var.secrets_manager.use_secrets_manager
  add_kms_block_storage_s2s = var.add_kms_block_storage_s2s
}

##############################################################################
