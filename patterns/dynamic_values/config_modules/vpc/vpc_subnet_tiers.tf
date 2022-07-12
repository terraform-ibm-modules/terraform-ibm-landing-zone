##############################################################################
# [Unit Test] Default VPC Subnet Tiers
##############################################################################

module "default_vpc_subnet_tiers" {
  source                              = "../vpc_subnet_tiers"
  create_f5_network_on_management_vpc = false
  use_teleport                        = false
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["management", "workload"]
  f5_tiers                            = []
  add_edge_vpc                        = false
  teleport_management_zones           = 0
}

locals {
  default_vpc_subnet_tiers_network_length  = regex("2", length(keys(module.default_vpc_subnet_tiers.value)))
  default_vpc_subnet_tiers_mgmt_z1_3_tiers = regex("3", length(module.default_vpc_subnet_tiers.value["management"].zone-1))
  default_vpc_subnet_tiers_mgmt_3_vpn      = regex("vpn", module.default_vpc_subnet_tiers.value["management"].zone-1[2])
  default_vpc_subnet_tiers_rest_same = regex("true", tostring(
    length(
      distinct(
        flatten(
          [
            for network in module.default_vpc_subnet_tiers.value :
            [
              for zone in concat(network != "management" ? ["zone-1"] : [], ["zone-2", "zone-3"]) :
              [
                for tier in ["vsi", "vpe"] :
                contains(network[zone], tier)
              ]
            ]
          ]
        )
      )
    ) == 1
  ))
}

##############################################################################

##############################################################################
# [Unit Test] F5 Edge Subnet tiers
##############################################################################

module "f5_edge_vpc_subnet_tiers" {
  source                              = "../vpc_subnet_tiers"
  create_f5_network_on_management_vpc = false
  use_teleport                        = true
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["edge", "management", "workload"]
  f5_tiers                            = ["f5-management", "f5-external", "f5-workload", "f5-bastion"]
  add_edge_vpc                        = true
  teleport_management_zones           = 0
}

locals {
  f5_edge_vpc_subnet_tiers_network_length  = regex("3", length(keys(module.f5_edge_vpc_subnet_tiers.value)))
  f5_edge_vpc_subnet_tiers_mgmt_z1_3_tiers = regex("3", length(module.f5_edge_vpc_subnet_tiers.value["management"].zone-1))
  f5_edge_vpc_subnet_tiers_mgmt_3_vpn      = regex("vpn", module.f5_edge_vpc_subnet_tiers.value["management"].zone-1[2])
  f5_edge_vpc_subnet_tiers_f5_match = regex("true", tostring(
    length(
      distinct(
        flatten(
          [
            for zone in ["zone-1", "zone-2", "zone-3"] :
            module.f5_edge_vpc_subnet_tiers.value["edge"][zone][0] == "f5" && length(module.f5_edge_vpc_subnet_tiers.value["edge"][zone]) == 0
          ]
        )
      )
    ) == 1
  ))
  f5_edge_vpc_subnet_tiers_rest_same = regex("true", tostring(
    length(
      distinct(
        flatten(
          [
            for network in ["management", "workload"] :
            [
              for zone in concat(network != "management" ? ["zone-1"] : [], ["zone-2", "zone-3"]) :
              [
                for tier in ["vsi", "vpe"] :
                contains(module.f5_edge_vpc_subnet_tiers.value[network][zone], tier)
              ]
            ]
          ]
        )
      )
    ) == 1
  ))
}

##############################################################################

##############################################################################
# [Unit Test] F5 Management Subnet tiers
##############################################################################

module "f5_management_vpc_subnet_tiers" {
  source                              = "../vpc_subnet_tiers"
  create_f5_network_on_management_vpc = true
  use_teleport                        = true
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["management", "workload"]
  f5_tiers                            = ["f5", "f6", "f7"]
  add_edge_vpc                        = true
  teleport_management_zones           = 0
}

locals {
  f5_management_vpc_subnet_tiers_network_length = regex("2", length(keys(module.f5_management_vpc_subnet_tiers.value)))
  f5_management_vpc_subnet_tiers_f5_match       = regex("f5;f6;f7;vsi;vpn", join(";", module.f5_management_vpc_subnet_tiers.value["management"]["zone-1"]))
  f5_management_vpc_subnet_tiers_rest_same = regex("true", tostring(
    length(
      distinct(
        flatten(
          [
            for zone in ["zone-1", "zone-2", "zone-3"] :
            [
              for tier in ["vsi", "vpe"] :
              contains(module.f5_management_vpc_subnet_tiers.value["workload"][zone], tier)
            ]
          ]
        )
      )
    ) == 1
  ))
}

##############################################################################


##############################################################################
# [Unit Test] Management Teleport Subnet Tiers
##############################################################################

module "management_teleport_subnet_tiers" {
  source                              = "../vpc_subnet_tiers"
  create_f5_network_on_management_vpc = false
  use_teleport                        = true
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["management", "workload"]
  f5_tiers                            = []
  add_edge_vpc                        = false
  teleport_management_zones           = 3
}

locals {
  management_teleport_subnet_tiers_network_length  = regex("2", length(keys(module.management_teleport_subnet_tiers.value)))
  management_teleport_subnet_tiers_mgmt_z1_4_tiers = regex("4", length(module.management_teleport_subnet_tiers.value["management"].zone-1))
  management_teleport_subnet_tiers_mgmt_3_bastion  = regex("bastion", module.management_teleport_subnet_tiers.value["management"].zone-1[3])
  management_teleport_subnet_tiers_bastion_zone_2_3 = regex("true", tostring(
    length(
      distinct(
        flatten(
          [
            for zone in ["zone-2", "zone-3"] :
            [
              for tier in ["vsi", "vpe", "bastion"] :
              contains(module.management_teleport_subnet_tiers.value["management"][zone], ["tier"])
            ]
          ]
        )
      )
    ) == 1
  ))
}

##############################################################################