data "ibm_is_vpc" "example" {
  depends_on = [
    module.vpc
  ]
  for_each = var.enable_transit_gateway ? toset(var.transit_gateway_connections) : toset([])
  name     = "${var.prefix}-${each.key}-vpc"
}


##############################################################################
# Transit Gateway
##############################################################################

resource "ibm_tg_gateway" "transit_gateway" {
  count          = var.enable_transit_gateway ? 1 : 0
  name           = "${var.prefix}-transit-gateway"
  location       = var.region
  global         = false
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

  for_each     = var.enable_transit_gateway ? data.ibm_is_vpc.example : {}
  gateway      = ibm_tg_gateway.transit_gateway[0].id
  network_type = "vpc"
  name         = "${var.prefix}-${each.key}-hub-connection"
  network_id   = each.value.crn
  timeouts {
    create = "30m"
    delete = "30m"
  }
}

##############################################################################
