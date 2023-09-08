
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


##############################################################################
# Transit Gateway Connections
##############################################################################

resource "ibm_tg_connection" "connection" {
  for_each     = var.enable_transit_gateway ? toset(var.transit_gateway_connections) : toset([])
  gateway      = ibm_tg_gateway.transit_gateway[0].id
  network_type = "vpc"
  name         = "${var.prefix}-${each.key}-hub-connection"
  network_id   = module.vpc[each.key].vpc_crn
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

##############################################################################
