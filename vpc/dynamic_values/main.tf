##############################################################################
# Address Prefixes
##############################################################################

locals {
  # For each address prefix
  address_prefixes = var.address_prefixes == null ? [] : flatten([
    # For each zone
    for zone in [
      for zone in ["zone-1", "zone-2", "zone-3"] :
      zone if var.address_prefixes[zone] != null && length(
        // If zone is null return empty array, otherwise get zone length
        var.address_prefixes[zone] == null ? [] : var.address_prefixes[zone]
      ) > 0
    ] :
    [
      for address in var.address_prefixes[zone] :
      # Return object containing name, zone, and CIDR
      {
        name = "${var.prefix}-${zone}-${index(var.address_prefixes[zone], address) + 1}"
        cidr = address
        zone = "${var.region}-${index(keys(var.address_prefixes), zone) + 1}"
      }
    ]
  ])
}

##############################################################################

##############################################################################
# Routes
##############################################################################

locals {
  routes_map = {
    # Convert routes from list to map
    for route in var.routes :
    (route.name) => route
  }
}

##############################################################################

##############################################################################
# Public Gateways
##############################################################################

locals {
  # create object that only contains gateways that will be created
  gateway_map = {
    for zone in keys(var.use_public_gateways) :
    zone => "${var.region}-${index(keys(var.use_public_gateways), zone) + 1}" if lookup(var.use_public_gateways, zone, null) == true
  }
}

##############################################################################

##############################################################################
# Security Group Rules
##############################################################################

locals {
  # Convert to object
  security_group_rule_object = {
    for rule in var.security_group_rules :
    rule.name => rule
  }
}

##############################################################################