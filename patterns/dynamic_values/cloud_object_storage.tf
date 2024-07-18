##############################################################################
# Cloud Object Storage
##############################################################################

module "cloud_object_storage" {
  source                            = "./config_modules/cloud_object_storage"
  prefix                            = var.prefix
  vpc_list                          = local.vpc_list
  bastion_resource_list             = local.bastion_resource_list
  use_random_cos_suffix             = var.use_random_cos_suffix
  existing_cos_instance_name        = var.existing_cos_instance_name
  existing_cos_resource_group       = var.existing_cos_resource_group
  use_existing_cos_for_atracker     = var.use_existing_cos_for_atracker
  use_existing_cos_for_vpc_flowlogs = var.use_existing_cos_for_vpc_flowlogs
  endpoint_type                     = var.existing_cos_endpoint_type
}

##############################################################################

##############################################################################
# [Unit Test] COS with Bastion
##############################################################################

module "cos_with_bastion" {
  source                = "./config_modules/cloud_object_storage"
  prefix                = "ut"
  vpc_list              = ["edge", "management", "workload"]
  bastion_resource_list = ["bastion"]
}

locals {
  cos_bastion_correct_instances       = regex("2", length(module.cos_with_bastion.value))
  cos_bastion_correct_service_buckets = regex("4", length(module.cos_with_bastion.value[1].buckets))
  cos_bastion_correct_bastion_bucket  = regex("bastion-bucket", module.cos_with_bastion.value[1].buckets[3].name)
  cos_bastion_correct_key             = regex("bastion-key", module.cos_with_bastion.value[1].keys[0].name)
}

##############################################################################

##############################################################################
# [Unit Test] COS without Bastion
##############################################################################

module "cos_no_bastion" {
  source                = "./config_modules/cloud_object_storage"
  prefix                = "ut"
  vpc_list              = ["management", "workload"]
  bastion_resource_list = []
}

locals {
  cos_no_bastion_correct_instances       = regex("2", length(module.cos_no_bastion.value))
  cos_no_bastion_correct_service_buckets = regex("2", length(module.cos_no_bastion.value[1].buckets))
  cos_no_bastion_correct_keys            = regex("0", length(module.cos_no_bastion.value[1].keys))
}

##############################################################################
