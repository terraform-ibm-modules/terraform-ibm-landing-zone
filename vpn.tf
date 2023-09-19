##############################################################################
# VPN Gateway Locals
##############################################################################

locals {
  vpn_gateway_map = module.dynamic_values.vpn_gateway_map
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

##############################################################################
