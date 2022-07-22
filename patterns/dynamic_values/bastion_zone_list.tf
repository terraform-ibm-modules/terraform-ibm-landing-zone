##############################################################################
# Bastion Zone List
##############################################################################

module "bastion_zone_list" {
  source                    = "./config_modules/bastion_zone_list"
  provision_teleport_in_f5  = var.provision_teleport_in_f5
  teleport_management_zones = var.teleport_management_zones
}

##############################################################################

##############################################################################
# [Unit Test] Teleport on F5
##############################################################################

module "bastion_zone_list_teleport_on_f5_ut" {
  source                    = "./config_modules/bastion_zone_list"
  provision_teleport_in_f5  = true
  teleport_management_zones = 0
}

locals {
  bastion_zones_assert_3_zones = regex("3", tostring(length(module.bastion_zone_list_teleport_on_f5_ut.value)))
}

##############################################################################

##############################################################################
# [Unit Test] 0 Teleport Management Zones
##############################################################################

module "bastion_zone_list_teleport_0_zones_no_f5" {
  source                    = "./config_modules/bastion_zone_list"
  provision_teleport_in_f5  = false
  teleport_management_zones = 0
}

locals {
  bastion_zones_assert_0_zones = regex("0", tostring(length(module.bastion_zone_list_teleport_0_zones_no_f5.value)))
}

##############################################################################


##############################################################################
# [Unit Test] 2 Teleport Management Zones
##############################################################################

module "bastion_zone_list_teleport_2_zones_no_f5" {
  source                    = "./config_modules/bastion_zone_list"
  provision_teleport_in_f5  = false
  teleport_management_zones = 2
}

locals {
  bastion_zones_assert_2_zones = regex("2", tostring(length(module.bastion_zone_list_teleport_2_zones_no_f5.value)))
}

##############################################################################
