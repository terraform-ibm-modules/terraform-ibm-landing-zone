##############################################################################
# Static Locals
##############################################################################

locals {
  # Static reference for vpc with no gateways
  vpc_gateways = {
    zone-1 = false
    zone-2 = false
    zone-3 = false
  }

  # Static list for bastion tiers by type
  vpn_firewall_types = {
    full-tunnel = ["f5-management", "f5-external", "f5-bastion"]
    waf         = ["f5-management", "f5-external", "f5-workload"]
    vpn-and-waf = ["f5-management", "f5-external", "f5-workload", "f5-bastion"]
  }
}

##############################################################################

##############################################################################
# Dynamic Locals
##############################################################################

locals {
  bastion_resource_list = var.provision_teleport_in_f5 == true || local.use_management_zones ? ["bastion"] : []     # ["bastion"] if using teleport [] if not
  bastion_vpc           = local.use_management_zones ? var.vpcs[0] : local.vpc_list[0]                              # if bastion on management, management, otherwise vpc where f5 provisioned
  f5_deployment_zones   = var.vpn_firewall_type != null && local.use_f5 ? [1, 2, 3] : []                            # three zones if using f5
  f5_network_rg         = "${var.prefix}-${local.vpc_list[0]}-rg"                                                   # f5 network resource group
  f5_teleport_zones     = var.teleport_management_zones <= 0 && local.use_teleport && local.use_f5 ? [1, 2, 3] : [] # If using f5 and teleport not on management three zones, otherwise 0
  use_f5                = var.add_edge_vpc || var.create_f5_network_on_management_vpc                               # true if pattern using f5
  use_management_zones  = var.teleport_management_zones > 0                                                         # true if teleport zones in management
  use_teleport          = length(local.bastion_resource_list) > 0                                                   # true if bastion resources are created
  vpc_list              = var.add_edge_vpc ? concat(["edge"], var.vpcs) : var.vpcs
}

##############################################################################

##############################################################################
# Compiled Locals
##############################################################################

locals {
  bastion_zone_list              = module.bastion_zone_list.value
  default_vsi_sg_rules           = module.default_vsi_sg_rules.rules
  default_vsi_sg_rules_force_tcp = module.default_vsi_sg_rules.all_tcp_rules
  f5_deployments                 = module.f5_deployments.value
  f5_security_group_rules        = module.f5_security_group_rules.management_bastion_rules
  f5_tiers                       = module.f5_tiers.value
  key_management                 = module.key_management.value
  object_storage                 = module.cloud_object_storage.value
  resource_groups                = module.resource_groups.value
  teleport_vsi                   = module.bastion_vsi_list.value
  vpcs                           = module.vpcs.value
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  f5_security_groups = {
    f5-management = module.security_groups.f5_management
    f5-external   = module.security_groups.f5_external
    f5-workload   = module.security_groups.f5_workload
    f5-bastion    = module.security_groups.f5_bastion
    bastion-vsi   = module.security_groups.bastion_vsi
  }
}

##############################################################################


##############################################################################
# Values used in VPC configuration
##############################################################################

locals {

  ##############################################################################
  # Security Groups
  ##############################################################################

  security_groups = [
    for tier in flatten(
      [
        local.use_teleport && local.use_f5
        # if using teleport and use f5 add bastion vsi group
        ? concat(local.vpn_firewall_types[var.vpn_firewall_type], ["bastion-vsi"])
        : local.use_f5
        # if using f5 and not teleport list of security groups
        ? local.vpn_firewall_types[var.vpn_firewall_type]
        : var.teleport_management_zones > 0
        # if using teleport and not f5, use bastion security group
        ? ["bastion-vsi"]
        : []
      ]
    ) :
    local.f5_security_groups[tier]
  ]

  ##############################################################################

  ##############################################################################
  # VPN Gateway
  # > Create a gateway in first vpc
  ##############################################################################

  vpn_gateways = [
    {
      name           = "${var.vpcs[0]}-gateway"
      vpc_name       = "${var.vpcs[0]}"
      subnet_name    = "vpn-zone-1"
      resource_group = "${var.prefix}-${var.vpcs[0]}-rg"
      connections    = []
    }
  ]

  ##############################################################################
}

##############################################################################
