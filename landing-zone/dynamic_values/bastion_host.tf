##############################################################################
# Bastion VSI Dynamic Values
##############################################################################

module "bastion_vsi_map" {
  source      = "./config_modules/bastion_vsi_list_to_map"
  prefix      = var.prefix
  vpc_modules = var.vpc_modules
  vsi_list    = var.bastion_vsi
}

##############################################################################

##############################################################################
# [Unit Test] VSI List to Map
##############################################################################

module "ut_vsi_list_to_map" {
  source = "./config_modules/bastion_vsi_list_to_map"
  prefix = "ut"
  vpc_modules = {
    management = {
      vpc_id = "mgmt"
      subnet_zone_list = [
        {
          name = "ut-management-bad-subnet"
        },
        {
          name = "ut-management-good-subnet"
        }
      ]
    }
    workload = {
      vpc_id = "wkld"
      subnet_zone_list = [
        {
          name = "ut-workload-bad-subnet"
        },
        {
          name = "ut-workload-good-subnet"
        }
      ]
    }
  }
  vsi_list = [
    {
      name        = "management-vsi"
      vpc_name    = "management"
      subnet_name = "good-subnet"
    },
    {
      name        = "workload-vsi"
      vpc_name    = "workload"
      subnet_name = "good-subnet"
    }
  ]
}

locals {
  assert_vsi_map_has_correct_management_vpc_id      = regex("mgmt", module.ut_vsi_list_to_map.value["ut-management-vsi"].vpc_id)
  assert_vsi_map_has_correct_management_subnets     = regex("1", length(module.ut_vsi_list_to_map.value["ut-management-vsi"].subnets))
  assert_vsi_map_has_correct_management_subnet_name = regex("ut-management-good-subnet", module.ut_vsi_list_to_map.value["ut-management-vsi"].subnets[0].name)
  assert_vsi_map_has_correct_workload_vpc_id        = regex("wkld", module.ut_vsi_list_to_map.value["ut-workload-vsi"].vpc_id)
  assert_vsi_map_has_correct_workload_subnets       = regex("1", length(module.ut_vsi_list_to_map.value["ut-workload-vsi"].subnets))
  assert_vsi_map_has_correct_workload_subnet_name   = regex("ut-workload-good-subnet", module.ut_vsi_list_to_map.value["ut-workload-vsi"].subnets[0].name)
}

##############################################################################
