##############################################################################
# Key Protect
##############################################################################

module "key_management" {
  source = "./kms"
  region = var.region
  key_management = {
    name              = var.key_management.name
    resource_group_id = var.key_management.resource_group == null ? null : local.resource_groups[var.key_management.resource_group]
    use_data          = var.key_management.use_data
    use_hs_crypto     = var.key_management.use_hs_crypto
  }
  keys = var.key_management.keys == null ? [] : var.key_management.keys
}


##############################################################################
