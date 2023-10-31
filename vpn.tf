##############################################################################
# VPN Gateway Locals
##############################################################################

locals {
  vpn_gateway_map    = module.dynamic_values.vpn_gateway_map
  vpn_connection_map = module.dynamic_values.vpn_connection_map
}

##############################################################################


##############################################################################
# Create VPN Gateways
##############################################################################

resource "ibm_is_vpn_gateway" "gateway" {
  for_each       = local.vpn_gateway_map
  name           = "${var.prefix}-${each.key}"
  subnet         = each.value.subnet_id
  mode           = each.value.mode
  resource_group = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  tags           = var.tags
  access_tags    = each.value.access_tags

  timeouts {
    delete = "1h"
  }
}

resource "ibm_is_vpn_gateway_connection" "gateway_connection" {
  for_each       = local.vpn_connection_map
  name           = each.value.connection_name
  vpn_gateway    = ibm_is_vpn_gateway.gateway[each.value.gateway_name].id
  peer_address   = each.value.peer_address
  preshared_key  = each.value.preshared_key
  local_cidrs    = each.value.local_cidrs
  peer_cidrs     = each.value.peer_cidrs
  admin_state_up = each.value.admin_state_up
}

##############################################################################
