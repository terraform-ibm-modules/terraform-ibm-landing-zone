##############################################################################
# Key Management
##############################################################################

module "key_management" {
  source                        = "./config_modules/key_management"
  prefix                        = var.prefix
  name                          = coalesce(var.hs_crypto_instance_name, var.existing_kms_instance_name, "${var.prefix}-slz-kms")
  resource_group                = coalesce(var.hs_crypto_resource_group, var.existing_kms_resource_group, "${var.prefix}-service-rg")
  use_hs_crypto                 = var.hs_crypto_instance_name == null ? false : true
  use_data                      = var.existing_kms_instance_name == null ? false : true
  add_vsi_volume_encryption_key = var.add_vsi_volume_encryption_key
  add_cluster_encryption_key    = var.add_cluster_encryption_key
}

##############################################################################

##############################################################################
# [Unit Test] Key Management No Additional Keys
##############################################################################

module "key_management_base_keys" {
  source                        = "./config_modules/key_management"
  prefix                        = "ut"
  name                          = "ut-kms"
  resource_group                = "ut-service-rg"
  use_hs_crypto                 = false
  add_vsi_volume_encryption_key = false
  add_cluster_encryption_key    = false
  use_data                      = false
}

locals {
  base_keys_creates_only_two_keys = regex("2", length(module.key_management_base_keys.value.keys))
}

##############################################################################

##############################################################################
# [Unit Test] Key Management Create All Keys
##############################################################################

module "key_management_all_keys" {
  source                        = "./config_modules/key_management"
  prefix                        = "ut"
  name                          = "ut-kms"
  resource_group                = "ut-service-rg"
  use_hs_crypto                 = false
  add_vsi_volume_encryption_key = true
  add_cluster_encryption_key    = true
  use_data                      = false
}

locals {
  all_keys_creates_only_two_keys = regex("4", length(module.key_management_all_keys.value.keys))
}

##############################################################################
