##############################################################################
# Default Security Group Rules
##############################################################################

module "default_vsi_sg_rules" {
  source = "./config_modules/default_security_group_rules"
}

##############################################################################

##############################################################################
# F5 Bastion Tier Rules
##############################################################################

module "f5_security_group_rules" {
  source            = "./config_modules/f5_security_group_rules"
  f5_teleport_zones = local.f5_teleport_zones
  f5_tiers          = local.f5_tiers
}

##############################################################################

##############################################################################
# Dynamic Security Groups
##############################################################################

module "security_groups" {
  source              = "./config_modules/security_groups"
  bastion_vpc_name    = local.bastion_vpc
  bastion_vsi_rules   = concat(local.default_vsi_sg_rules_force_tcp, module.f5_security_group_rules.bastion_vsi_rules)
  f5_bastion_rules    = module.f5_security_group_rules.bastion_rules
  f5_management_rules = concat(local.f5_security_group_rules, local.default_vsi_sg_rules_force_tcp)
  f5_external_rules   = module.f5_security_group_rules.external_rules
  f5_resource_group   = local.f5_network_rg
  f5_vpc_name         = local.vpc_list[0]
  f5_workload_rules   = concat(module.f5_security_group_rules.workload_rules, local.default_vsi_sg_rules_force_tcp)
  prefix              = var.prefix
}

##############################################################################
