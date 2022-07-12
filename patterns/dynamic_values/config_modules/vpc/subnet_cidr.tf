##############################################################################
# [Unit Test] F5 on Managment
##############################################################################

module "ut_f5_on_management_cidr" {
  source            = "../subnet_cidr"
  network           = "management"
  f5_tiers          = ["vpn-1", "vpn-2", "f5-management", "f5-external", "f5-workload", "f5-bastion"]
  vpc_list          = ["management", "workload"]
  use_f5            = true
  vpcs              = ["management", "workload"]
  vpn_firewall_type = "vpn-and-waf"
  subnet_tiers = {
    zone-1 = ["vpn-1", "vpn-2", "f5-management", "f5-external", "f5-workload", "f5-bastion", "vsi", "vpe", "vpn"]
    zone-2 = ["vpn-1", "vpn-2", "f5-management", "f5-external", "f5-workload", "f5-bastion", "vsi", "vpe"]
    zone-3 = ["vpn-1", "vpn-2", "f5-management", "f5-external", "f5-workload", "f5-bastion", "vsi", "vpe"]
  }
}

locals {
  join                                   = join(";", keys(module.ut_f5_on_management_cidr.value["zone-1"]))
  assert_f5_mgmt_zone_1_correct_tiers    = regex("f5-bastion;f5-external;f5-management;f5-workload;vpe;vpn;vpn-1;vpn-2;vsi", local.join)
  assert_f5_mgmt_zone_1_vpn_correct_cidr = regex("10.10.30.0/24", module.ut_f5_on_management_cidr.value["zone-1"].vpn)
}

##############################################################################