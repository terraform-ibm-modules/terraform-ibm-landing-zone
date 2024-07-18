##############################################################################
# Resource Group Values
##############################################################################

module "resource_groups" {
  source                      = "./config_modules/resource_groups"
  prefix                      = var.prefix
  vpc_list                    = local.vpc_list
  hs_crypto_resource_group    = var.hs_crypto_resource_group == null ? [] : [var.hs_crypto_resource_group]
  appid_resource_group        = var.appid_resource_group == null ? [] : [var.appid_resource_group]
  existing_kms_resource_group = var.existing_kms_resource_group == null ? [] : [var.existing_kms_resource_group]
  existing_cos_resource_group = var.existing_cos_resource_group == null ? [] : [var.existing_cos_resource_group]
}

##############################################################################

##############################################################################
# [Unit Test] Resource Base Group Values
##############################################################################

module "resource_groups_base" {
  source                      = "./config_modules/resource_groups"
  prefix                      = "ut"
  vpc_list                    = ["management", "workload"]
  hs_crypto_resource_group    = []
  appid_resource_group        = []
  existing_kms_resource_group = []
  existing_cos_resource_group = []
}

locals {
  base_resource_group_contains_3_groups = regex("3", tostring(length(module.resource_groups_base.value)))
  base_rg_names                         = module.resource_groups_base.value.*.name
  base_rg_contains_management           = regex("true", tostring(contains(local.base_rg_names, "ut-management-rg")))
  base_rg_contains_service              = regex("true", tostring(contains(local.base_rg_names, "ut-management-rg")))
  base_rg_contains_workload             = regex("true", tostring(contains(local.base_rg_names, "ut-workload-rg")))
}

##############################################################################

##############################################################################
# [Unit Test] Resource All Group Values
##############################################################################

module "resource_groups_all" {
  source                      = "./config_modules/resource_groups"
  prefix                      = "ut"
  vpc_list                    = ["management", "workload"]
  hs_crypto_resource_group    = ["Default"]
  appid_resource_group        = ["appid-rg"]
  existing_kms_resource_group = []
  existing_cos_resource_group = []
}

locals {
  all_resource_group_contains_4_groups = regex("5", tostring(length(module.resource_groups_all.value)))
  all_rg_names                         = module.resource_groups_all.value.*.name
  all_rg_contains_default              = regex("true", tostring(contains(local.all_rg_names, "Default")))
  all_rg_does_not_create_default       = regex("false", tostring(module.resource_groups_all.value[1].create))
  all_rg_contains_management           = regex("true", tostring(contains(local.all_rg_names, "ut-management-rg")))
  all_rg_contains_service              = regex("true", tostring(contains(local.all_rg_names, "ut-management-rg")))
  all_rg_contains_workload             = regex("true", tostring(contains(local.all_rg_names, "ut-workload-rg")))
  all_rg_contains_appid                = regex("true", tostring(contains(local.all_rg_names, "appid-rg")))

}

##############################################################################
