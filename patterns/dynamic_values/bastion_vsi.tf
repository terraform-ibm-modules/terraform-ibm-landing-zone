##############################################################################
# Bastion VSI List
##############################################################################

module "bastion_vsi_list" {
  source                    = "./config_modules/bastion_vsi"
  bastion_zone_list         = local.bastion_zone_list
  vpc_name                  = local.bastion_vpc
  prefix                    = var.prefix
  teleport_vsi_image_name   = var.teleport_vsi_image_name
  teleport_instance_profile = var.teleport_instance_profile
}

##############################################################################

##############################################################################
# Bastion 1 Zone
##############################################################################

module "bastion_1_zone" {
  source                    = "./config_modules/bastion_vsi"
  bastion_zone_list         = [1]
  vpc_name                  = "unit-test"
  prefix                    = "ut"
  teleport_vsi_image_name   = "ut-image"
  teleport_instance_profile = "ut-1x1"
}

locals {
  zone_1_bastion_vsi                 = module.bastion_1_zone.value[0]
  zone_1_bastion_correct_name        = regex("bastion-1", local.zone_1_bastion_vsi.name)
  zone_1_bastion_correct_subnet_name = regex("bastion-zone-1", local.zone_1_bastion_vsi.subnet_name)
  zone_1_bastion_correct_rg          = regex("ut-unit-test-rg", local.zone_1_bastion_vsi.resource_group)
  zone_1_bastion_correct_key         = regex("ut-vsi-volume-key", local.zone_1_bastion_vsi.boot_volume_encryption_key_name)
}

##############################################################################

##############################################################################
# Bastion 3 Zone
##############################################################################

module "bastion_3_zone" {
  source                    = "./config_modules/bastion_vsi"
  bastion_zone_list         = [1, 2, 3]
  vpc_name                  = "unit-test"
  prefix                    = "ut"
  teleport_vsi_image_name   = "ut-image"
  teleport_instance_profile = "ut-1x1"
}

locals {
  bastion_3_zone_correct_vsi_length = regex("3", length(module.bastion_3_zone.value))
}

##############################################################################