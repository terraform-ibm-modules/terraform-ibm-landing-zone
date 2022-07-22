##############################################################################
# F5 Deployment Instances
##############################################################################

module "f5_deployments" {
  source                   = "./config_modules/f5_deployments"
  prefix                   = var.prefix
  f5_vpc_name              = local.vpc_list[0]
  f5_resource_group        = local.f5_network_rg
  f5_zones                 = local.f5_deployment_zones
  f5_image_name            = var.f5_image_name
  f5_instance_profile      = var.f5_instance_profile
  domain                   = var.domain
  hostname                 = var.hostname
  enable_f5_management_fip = var.enable_f5_management_fip
  enable_f5_external_fip   = var.enable_f5_external_fip
  f5_network_tiers         = var.vpn_firewall_type == null ? [] : local.vpn_firewall_types[var.vpn_firewall_type]
}

##############################################################################

##############################################################################
# [Unit Test] F5 Deployments 0 Zones
##############################################################################

module "f5_deployments_0_zones" {
  source                   = "./config_modules/f5_deployments"
  prefix                   = "ut"
  f5_vpc_name              = "vpc"
  f5_resource_group        = "rg"
  f5_zones                 = []
  f5_image_name            = "f5-bigip-16-1-2-2-0-0-28-all-1slot"
  f5_instance_profile      = "uxt-1x2"
  domain                   = "unit.test"
  hostname                 = "unit-test"
  enable_f5_management_fip = false
  enable_f5_external_fip   = false
  f5_network_tiers         = []
}

locals {
  f5_deployments_0_zones_0_deployments = regex("0", length(module.f5_deployments_0_zones.value))
}

##############################################################################

##############################################################################
# [Unit Test] F5 Deployments 3 Zones
##############################################################################

module "f5_deployments_3_zones" {
  source                   = "./config_modules/f5_deployments"
  prefix                   = "ut"
  f5_vpc_name              = "vpc"
  f5_resource_group        = "rg"
  f5_zones                 = [1, 2, 3]
  f5_image_name            = "f5-bigip-16-1-2-2-0-0-28-all-1slot"
  f5_instance_profile      = "uxt-1x2"
  domain                   = "unit.test"
  hostname                 = "unit-test"
  enable_f5_management_fip = false
  enable_f5_external_fip   = false
  f5_network_tiers         = ["f5-management", "f5-external", "f5-workload"]
}

locals {
  f5_deployments_3_zones_3_deployments                     = regex("3", length(module.f5_deployments_3_zones.value))
  f5_deployments_3_zones_2_secondary_subnets               = regex("2", length(module.f5_deployments_3_zones.value[0].secondary_subnet_names))
  f5_deployments_3_zones_2_secondary_security_groups       = regex("2", length(module.f5_deployments_3_zones.value[0].secondary_subnet_security_group_names))
  f5_deployments_3_zones_2_secondary_subnets_no_management = regex("false", tostring(contains(module.f5_deployments_3_zones.value[0].secondary_subnet_names, "f5-management")))
  f5_deployments_3_zones_2_secondary_subnets_has_external  = regex("true", tostring(contains(module.f5_deployments_3_zones.value[0].secondary_subnet_names, "f5-external-zone-1")))
  f5_deployments_3_zones_2_secondary_subnets_has_workload  = regex("true", tostring(contains(module.f5_deployments_3_zones.value[0].secondary_subnet_names, "f5-workload-zone-1")))

}
##############################################################################
