##############################################################################
# F5 Tiers List
##############################################################################

module "f5_tiers" {
  source                   = "./config_modules/f5_tiers"
  provision_teleport_in_f5 = var.provision_teleport_in_f5
  vpn_firewall_type        = var.vpn_firewall_type
  vpn_firewall_types       = local.vpn_firewall_types
}

##############################################################################

##############################################################################
# [Unit Test] F5 No Values
##############################################################################

module "f5_tiers_no_values" {
  source                   = "./config_modules/f5_tiers"
  provision_teleport_in_f5 = false
  vpn_firewall_type        = null
  vpn_firewall_types       = local.vpn_firewall_types
}

locals {
  f5_tiers_no_values_correct_tiers = regex("1", length(module.f5_tiers_no_values.value))
}

##############################################################################

##############################################################################
# [Unit Test] F5 VPN and WAF with Bastion
##############################################################################

module "f5_tiers_vpn_waf_bastion" {
  source                   = "./config_modules/f5_tiers"
  provision_teleport_in_f5 = true
  vpn_firewall_type        = "vpn-and-waf"
  vpn_firewall_types       = local.vpn_firewall_types
}

locals {
  f5_tiers_vpn_waf_bastion_correct_tiers = regex("8", length(module.f5_tiers_vpn_waf_bastion.value))
}

##############################################################################

##############################################################################
# [Unit Test] F5 WAF no Bastion
##############################################################################

module "f5_tiers_waf_no_bastion" {
  source                   = "./config_modules/f5_tiers"
  provision_teleport_in_f5 = false
  vpn_firewall_type        = "waf"
  vpn_firewall_types       = local.vpn_firewall_types
}

locals {
  f5_tiers_waf_no_bastion_correct_tiers = regex("4", length(module.f5_tiers_waf_no_bastion.value))
}

##############################################################################
