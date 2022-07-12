
##############################################################################
# VPC Address Prefixes
##############################################################################

module "vpc_address_prefixes" {
  source                              = "../vpc_address_prefixes"
  vpcs                                = var.vpcs
  vpc_list                            = var.vpc_list
  add_edge_vpc                        = var.add_edge_vpc
  create_f5_network_on_management_vpc = var.create_f5_network_on_management_vpc
}

##############################################################################

##############################################################################
# Network ACLs
##############################################################################

module "network_acls" {
  source                     = "../network_acls"
  vpc_list                   = var.vpc_list
  use_teleport               = var.use_teleport
  use_f5                     = var.use_f5
  bastion_vpc_name           = var.bastion_vpc_name
  add_cluster_encryption_key = var.add_cluster_encryption_key
}

##############################################################################

##############################################################################
# VPC Subnet Tiers
##############################################################################

module "vpc_subnet_tiers" {
  source                              = "../vpc_subnet_tiers"
  create_f5_network_on_management_vpc = var.create_f5_network_on_management_vpc
  use_teleport                        = var.use_teleport
  vpcs                                = var.vpcs
  vpc_list                            = var.vpc_list
  f5_tiers                            = var.f5_tiers
  add_edge_vpc                        = var.add_edge_vpc
  teleport_management_zones           = var.teleport_management_zones
}

##############################################################################

##############################################################################
# Subnet CIDR
##############################################################################

module "subnet_cidr" {
  for_each          = module.vpc_subnet_tiers.value
  source            = "../subnet_cidr"
  network           = each.key
  subnet_tiers      = each.value
  f5_tiers          = var.f5_tiers
  vpc_list          = var.vpc_list
  use_f5            = var.use_f5
  vpcs              = var.vpcs
  vpn_firewall_type = var.vpn_firewall_type
}

##############################################################################

##############################################################################
# Bastion Zone List
##############################################################################

module "bastion_gateways" {
  source                    = "../bastion_gateways"
  provision_teleport_in_f5  = var.provision_teleport_in_f5
  teleport_management_zones = var.teleport_management_zones
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  # Static reference for vpc with no gateways
  vpc_gateways = {
    zone-1 = false
    zone-2 = false
    zone-3 = false
  }
}

##############################################################################

##############################################################################
# VPC Output
##############################################################################

output "value" {
  description = "List of VPCs for network"
  value = [
    for network in var.vpc_list :
    {
      default_security_group_rules = []
      prefix                       = network
      resource_group               = "${var.prefix}-${network}-rg"
      flow_logs_bucket_name        = "${network}-bucket"
      address_prefixes             = module.vpc_address_prefixes.value[network]
      network_acls                 = module.network_acls.value[network]
      use_public_gateways = (
        # If network is edge, use teleport and no teleport zones OR teleport zones is greater than 0 && management
        (network == var.vpc_list[0] && var.use_teleport && var.teleport_management_zones == 0) || (var.teleport_management_zones > 0 && network == var.vpcs[0])
        ? module.bastion_gateways.value
        : local.vpc_gateways
      )
      subnets = {
        for zone in [1, 2, 3] :
        "zone-${zone}" => [
          for subnet in keys(module.subnet_cidr[network].value["zone-${zone}"]) :
          {
            name           = "${subnet}-zone-${zone}"
            cidr           = module.subnet_cidr[network].value["zone-${zone}"][subnet]
            public_gateway = subnet == "bastion" ? true : null
            acl_name       = subnet == "bastion" ? "bastion-acl" : subnet == "f5-external" ? "f5-external-acl" : "${network}-acl"
          }
        ]
      }
    }
  ]
}

##############################################################################