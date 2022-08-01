##############################################################################
# Subnet Values
##############################################################################

locals {
  # Convert subnets into a single list
  subnet_list = flatten([
    # For each key in the object create an array
    for zone in [for zone in keys(var.subnets) : zone if var.subnets[zone] != null] :
    # Each item in the list contains information about a single subnet
    [
      for value in var.subnets[zone] :
      {
        name        = value.name                                            # Subnet shortname
        prefix_name = "${var.prefix}-${value.name}"                         # Creates a name of the prefix and subnet name
        zone        = index(keys(var.subnets), zone) + 1                    # Zone 1, 2, or 3
        zone_name   = "${var.region}-${index(keys(var.subnets), zone) + 1}" # Contains region and zone
        cidr        = value.cidr                                            # CIDR Block
        count       = index(var.subnets[zone], value) + 1                   # Count of the subnet within the zone
        acl         = value.acl_name
        # Public gateway ID
        public_gateway = (
          lookup(value, "public_gateway", null) == true && lookup(var.use_public_gateways, zone, null) != null
          ? (
            lookup(var.public_gateways, zone, null) == null ? null : var.public_gateways[zone].id
          )
          : null
        )
      }
    ]
  ])

  # Convert list to map
  subnet_map = {
    for subnet in local.subnet_list :
    "${var.prefix}-${subnet.name}" => subnet
  }
}

##############################################################################