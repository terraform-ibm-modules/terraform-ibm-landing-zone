##############################################################################
# [Unit Test] Teleport on F5
##############################################################################

module "bastion_gateways_teleport_on_f5_ut" {
  source                    = "../bastion_gateways"
  provision_teleport_in_f5  = true
  teleport_management_zones = 0
}

locals {
  bastion_gw_f5_zone_1_true = regex("true", tostring(module.bastion_gateways_teleport_on_f5_ut.value.zone-1))
  bastion_gw_f5_zone_2_true = regex("true", tostring(module.bastion_gateways_teleport_on_f5_ut.value.zone-2))
  bastion_gw_f5_zone_3_true = regex("true", tostring(module.bastion_gateways_teleport_on_f5_ut.value.zone-3))
}

##############################################################################


##############################################################################
# [Unit Test] 0 Teleport Management Zones
##############################################################################

module "bastion_gateways_teleport_0_zones_no_f5" {
  source                    = "../bastion_gateways"
  provision_teleport_in_f5  = false
  teleport_management_zones = 0
}

locals {
  bastion_gw_no_f5_zone_1_true = regex("false", tostring(module.bastion_gateways_teleport_0_zones_no_f5.value.zone-1))
  bastion_gw_no_f5_zone_2_true = regex("false", tostring(module.bastion_gateways_teleport_0_zones_no_f5.value.zone-2))
  bastion_gw_no_f5_zone_3_true = regex("false", tostring(module.bastion_gateways_teleport_0_zones_no_f5.value.zone-3))
}

##############################################################################


##############################################################################
# [Unit Test] 2 Teleport Management Zones
##############################################################################

module "bastion_gateways_teleport_2_zones_no_f5" {
  source                    = "../bastion_gateways"
  provision_teleport_in_f5  = false
  teleport_management_zones = 2
}

locals {
  bastion_gw_no_f5_teleport_2_zones_zone_1_true = regex("true", tostring(module.bastion_gateways_teleport_2_zones_no_f5.value.zone-1))
  bastion_gw_no_f5_teleport_2_zones_zone_2_true = regex("true", tostring(module.bastion_gateways_teleport_2_zones_no_f5.value.zone-2))
  bastion_gw_no_f5_teleport_2_zones_zone_3_true = regex("false", tostring(module.bastion_gateways_teleport_2_zones_no_f5.value.zone-3))
}

##############################################################################
