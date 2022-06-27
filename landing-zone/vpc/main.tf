##############################################################################
# Create new VPC
##############################################################################

resource "ibm_is_vpc" "vpc" {
  name                        = var.prefix != null ? "${var.prefix}-${var.name}-vpc" : "${var.name}-vpc"
  resource_group              = var.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management   = var.use_manual_address_prefixes == false ? null : "manual"
  default_network_acl_name    = var.default_network_acl_name
  default_security_group_name = var.default_security_group_name
  default_routing_table_name  = var.default_routing_table_name
  tags                        = var.tags
}

##############################################################################


##############################################################################
# Address Prefixes
##############################################################################

locals {
  # For each address prefix
  address_prefixes = {
    for prefix in module.dynamic_values.address_prefixes :
    (prefix.name) => prefix
  }
}

resource "ibm_is_vpc_address_prefix" "address_prefixes" {
  for_each = local.address_prefixes
  name     = each.value.name
  vpc      = ibm_is_vpc.vpc.id
  zone     = each.value.zone
  cidr     = each.value.cidr
}

##############################################################################


##############################################################################
# ibm_is_vpc_route: Create vpc route resource
##############################################################################

locals {
  routes_map = {
    # Convert routes from list to map
    for route in var.routes :
    (route.name) => route
  }
}

resource "ibm_is_vpc_route" "route" {
  for_each    = local.routes_map
  name        = "${var.prefix}-${var.name}-route-${each.value.name}"
  vpc         = ibm_is_vpc.vpc.id
  zone        = each.value.zone
  destination = each.value.destination
  next_hop    = each.value.next_hop
}

##############################################################################


##############################################################################
# Public Gateways (Optional)
##############################################################################

locals {
  # create object that only contains gateways that will be created
  gateway_object = {
    for zone in keys(var.use_public_gateways) :
    zone => "${var.region}-${index(keys(var.use_public_gateways), zone) + 1}" if var.use_public_gateways[zone]
  }
}

resource "ibm_is_public_gateway" "gateway" {
  for_each       = local.gateway_object
  name           = "${var.prefix}-${var.name}-public-gateway-${each.key}"
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id
  zone           = each.value
}

##############################################################################
