##############################################################################
# VPN Gateway Values
##############################################################################

module "vpn" {
  source       = "./config_modules/vpn"
  prefix       = var.prefix
  vpc_modules  = var.vpc_modules
  vpn_gateways = var.vpn_gateways
}

##############################################################################

##############################################################################
# [Unit Test] VPN Gateway Values
##############################################################################

module "ut_vpn" {
  source = "./config_modules/vpn"
  prefix = "ut"
  vpc_modules = {
    test = {
      vpc_id = "1234"
      subnet_zone_list = [
        {
          name = "ut-test-vpn-zone-1"
          id   = "vpn-id"
          zone = "vpn-zone"
          cidr = "vpn"
      }]
    }
  }
  vpn_gateways = [
    {
      connections = [{
        peer_address   = "test-peer-address"
        preshared_key  = "preshared_key"
        local_cidrs    = ["cidr1"]
        peer_cidrs     = ["cidr2"]
        admin_state_up = true
      }]
      name           = "test-gateway",
      resource_group = "test-rg"
      subnet_name    = "vpn-zone-1"
      vpc_name       = "test"
      mode           = null
    }
  ]
}

locals {
  assert_vpn_gateway_exists_in_map            = lookup(module.ut_vpn.vpn_gateway_map, "test-gateway")
  assert_vpn_gateway_correct_vpc_id           = regex("1234", module.ut_vpn.vpn_gateway_map["test-gateway"].vpc_id)
  assert_vpn_gateway_correct_subnet_id        = regex("vpn-id", module.ut_vpn.vpn_gateway_map["test-gateway"].subnet_id)
  assert_vpn_connection_correct_gateway_name  = regex("test-gateway", module.ut_vpn.vpn_connection_map["test-gateway-connection-1"].gateway_name)
  assert_vpn_connection_correct_preshared_key = regex("preshared_key", module.ut_vpn.vpn_connection_map["test-gateway-connection-1"].preshared_key)
}

##############################################################################
