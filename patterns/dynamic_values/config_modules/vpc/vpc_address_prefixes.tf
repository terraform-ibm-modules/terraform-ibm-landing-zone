##############################################################################
# [Unit Test] VPC Address Prefixes No F5
##############################################################################

module "vpc_address_prefixes_no_f5" {
  source                              = "../vpc_address_prefixes"
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["management", "workload"]
  add_edge_vpc                        = false
  create_f5_network_on_management_vpc = false
}

locals {
  vpc_address_prefixes_no_f5_two_networks        = regex("2", length(keys(module.vpc_address_prefixes_no_f5.value)))
  vpc_address_prefixes_no_f5_workload_no_address = regex("0", length(module.vpc_address_prefixes_no_f5.value["workload"].zone-2))
}

##############################################################################

##############################################################################
# [Unit Test] VPC Address Prefixes F5 Edge
##############################################################################

module "vpc_address_prefixes_f5_edge" {
  source                              = "../vpc_address_prefixes"
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["edge", "management", "workload"]
  add_edge_vpc                        = true
  create_f5_network_on_management_vpc = false
}

locals {
  vpc_address_prefixes_f5_edge_three_networks          = regex("3", length(keys(module.vpc_address_prefixes_f5_edge.value)))
  vpc_address_prefixes_f5_edge_workload_no_address     = regex("0", length(module.vpc_address_prefixes_f5_edge.value["workload"].zone-2))
  vpc_address_prefixes_f5_edge_correct_prefix_count_z1 = regex("1", length(module.vpc_address_prefixes_f5_edge.value["edge"].zone-1))
  vpc_address_prefixes_f5_edge_correct_prefix_count_z2 = regex("1", length(module.vpc_address_prefixes_f5_edge.value["edge"].zone-2))
  vpc_address_prefixes_f5_edge_correct_prefix_count_z3 = regex("1", length(module.vpc_address_prefixes_f5_edge.value["edge"].zone-3))
  vpc_address_prefixes_f5_edge_cidr_correct_z1         = regex("10.5.0.0/16", module.vpc_address_prefixes_f5_edge.value["edge"].zone-1[0])
  vpc_address_prefixes_f5_edge_cidr_correct_z2         = regex("10.6.0.0/16", module.vpc_address_prefixes_f5_edge.value["edge"].zone-2[0])
  vpc_address_prefixes_f5_edge_cidr_correct_z3         = regex("10.7.0.0/16", module.vpc_address_prefixes_f5_edge.value["edge"].zone-3[0])
}


##############################################################################

##############################################################################
# [Unit Test] VPC Address Prefixes F5 Management
##############################################################################

module "vpc_address_prefixes_f5_management" {
  source                              = "../vpc_address_prefixes"
  vpcs                                = ["management", "workload"]
  vpc_list                            = ["management", "workload"]
  add_edge_vpc                        = false
  create_f5_network_on_management_vpc = true
}

locals {
  vpc_address_prefixes_f5_management_three_networks          = regex("2", length(keys(module.vpc_address_prefixes_f5_management.value)))
  vpc_address_prefixes_f5_management_workload_no_address     = regex("0", length(module.vpc_address_prefixes_f5_management.value["workload"].zone-2))
  vpc_address_prefixes_f5_management_correct_prefix_count_z1 = regex("3", length(module.vpc_address_prefixes_f5_management.value["management"].zone-1))
  vpc_address_prefixes_f5_management_correct_prefix_count_z2 = regex("2", length(module.vpc_address_prefixes_f5_management.value["management"].zone-2))
  vpc_address_prefixes_f5_management_correct_prefix_count_z3 = regex("2", length(module.vpc_address_prefixes_f5_management.value["management"].zone-3))
  vpc_address_prefixes_f5_management_cidr_correct_z1         = regex("10.5.0.0/16", module.vpc_address_prefixes_f5_management.value["management"].zone-1[0])
  vpc_address_prefixes_f5_management_cidr_correct_z2         = regex("10.6.0.0/16", module.vpc_address_prefixes_f5_management.value["management"].zone-2[0])
  vpc_address_prefixes_f5_management_cidr_correct_z3         = regex("10.7.0.0/16", module.vpc_address_prefixes_f5_management.value["management"].zone-3[0])
  vpc_address_prefixes_f5_management_cidr_correct_z1_1       = regex("10.10.10.0/24", module.vpc_address_prefixes_f5_management.value["management"].zone-1[1])
  vpc_address_prefixes_f5_management_cidr_correct_z2_2       = regex("10.20.10.0/24", module.vpc_address_prefixes_f5_management.value["management"].zone-2[1])
  vpc_address_prefixes_f5_management_cidr_correct_z3_2       = regex("10.30.10.0/24", module.vpc_address_prefixes_f5_management.value["management"].zone-3[1])
}


##############################################################################