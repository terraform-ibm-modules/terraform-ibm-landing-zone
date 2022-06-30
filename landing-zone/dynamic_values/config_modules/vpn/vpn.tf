##############################################################################
# VPN Gateway Map For Subnets
##############################################################################

module "vpn_subnet_map" {
  source = "../list_to_map"
  list = [
    for gateway in var.vpn_gateways :
    {
      name            = gateway.name
      vpc_name        = gateway.vpc_name
      vpc_subnet_name = "${var.prefix}-${gateway.vpc_name}-${gateway.subnet_name}"
    }
  ]
}

##############################################################################

##############################################################################
# VPN Gateway Subnets
##############################################################################

module "vpn_gateway_subnets" {
  source           = "../get_subnets"
  for_each         = module.vpn_subnet_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = each.value.vpc_subnet_name
}

##############################################################################

##############################################################################
# VPN Gateway Map
##############################################################################

module "vpn_gateway_map" {
  source = "../list_to_map"
  list = [
    for gateway in var.vpn_gateways :
    {
      name           = gateway.name
      vpc_id         = var.vpc_modules[gateway.vpc_name].vpc_id
      subnet_id      = module.vpn_gateway_subnets[gateway.name].subnets[0].id
      mode           = gateway.mode
      connections    = gateway.connections
      resource_group = gateway.resource_group
    }
  ]
}

##############################################################################

##############################################################################
# VPN Gateway Connections
##############################################################################

module "vpn_connection_map" {
  source = "../list_to_map"
  list = flatten([
    for gateway in var.vpn_gateways :
    [
      for connection in gateway.connections :
      merge({
        gateway_name    = gateway.name
        connection_name = "${gateway.name}-connection-${index(gateway.connections, connection) + 1}"
      }, connection)
    ]
  ])
  key_name_field = "connection_name"
}

##############################################################################

##############################################################################
# VPN Gateway Outputs
##############################################################################

output "vpn_gateway_map" {
  description = "Map of VPN gateways"
  value       = module.vpn_gateway_map.value
}

output "vpn_connection_map" {
  description = "Connection map for VPN"
  value       = module.vpn_connection_map.value
}

##############################################################################
