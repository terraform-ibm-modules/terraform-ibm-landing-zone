##############################################################################
# Key Management
##############################################################################

module "key_management" {
  source                        = "./config_modules/key_management"
  prefix                        = var.prefix
  name                          = var.hs_crypto_instance_name == null ? "${var.prefix}-slz-kms" : var.hs_crypto_instance_name
  resource_group                = var.hs_crypto_resource_group == null ? "${var.prefix}-service-rg" : var.hs_crypto_resource_group
  use_hs_crypto                 = var.hs_crypto_instance_name == null ? false : true
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
}

locals {
  all_keys_creates_only_two_keys = regex("4", length(module.key_management_all_keys.value.keys))
}

##############################################################################