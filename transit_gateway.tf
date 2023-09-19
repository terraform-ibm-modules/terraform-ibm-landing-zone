
##############################################################################
# Transit Gateway
##############################################################################

resource "ibm_tg_gateway" "transit_gateway" {
  count          = var.enable_transit_gateway ? 1 : 0
  name           = "${var.prefix}-transit-gateway"
  location       = var.region
  global         = var.transit_gateway_global
  resource_group = local.resource_groups[var.transit_gateway_resource_group]

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

##############################################################################
