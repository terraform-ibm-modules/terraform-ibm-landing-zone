##############################################################################
# VPCs
##############################################################################

module "vpcs" {
  source                              = "./config_modules/vpc"
  prefix                              = var.prefix
  vpcs                                = var.vpcs
  vpc_list                            = local.vpc_list
  add_edge_vpc                        = var.add_edge_vpc
  create_f5_network_on_management_vpc = var.create_f5_network_on_management_vpc
  use_teleport                        = local.use_teleport
  use_f5                              = local.use_f5
  bastion_vpc_name                    = local.bastion_vpc
  add_cluster_encryption_key          = var.add_cluster_encryption_key
  f5_tiers                            = local.f5_tiers
  teleport_management_zones           = var.teleport_management_zones
  provision_teleport_in_f5            = var.provision_teleport_in_f5
  vpn_firewall_type                   = var.vpn_firewall_type
}

##############################################################################