##############################################################################
# VPE Services Map
##############################################################################

module "vpe_service_map" {
  source = "../list_to_map"
  list = [
    for endpoint in var.virtual_private_endpoints :
    {
      name = "${endpoint.service_name}-${endpoint.service_type}"
      crn  = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
      id   = var.cos_instance_ids[endpoint.service_name]
    }
  ]
}

##############################################################################

##############################################################################
# VPE Gateway Map
##############################################################################

module "vpe_gateway_map" {
  source = "../list_to_map"
  list = flatten([
    # fore each service
    for service in var.virtual_private_endpoints :
    [
      # for each VPC create an object for the endpoints to be created
      for vpcs in service.vpcs :
      {
        name                = "${vpcs.name}-${service.service_name}"
        vpc_id              = var.vpc_modules[vpcs.name].vpc_id
        resource_group      = lookup(service, "resource_group", null)
        security_group_name = lookup(vpcs, "security_group_name", null)
        crn                 = module.vpe_service_map.value["${service.service_name}-${service.service_type}"].crn
      }
    ]
  ])
}

##############################################################################

##############################################################################
# VPE IP Map For Subnets
##############################################################################

module "vpe_ip_map" {
  source         = "../list_to_map"
  key_name_field = "ip_name"
  list = flatten([
    # For each service
    for service in var.virtual_private_endpoints :
    [
      # For each VPC attached to that service
      for vpcs in service.vpcs :
      [
        # For each subnet where a VPE will be created
        for subnet in vpcs.subnets :
        # Create reserved IP object
        {
          vpc_name     = vpcs.name
          ip_name      = "${vpcs.name}-${service.service_name}-gateway-${subnet}-ip"
          gateway_name = "${vpcs.name}-${service.service_name}"
          subnet_name  = "${var.prefix}-${vpcs.name}-${subnet}"
        }
      ]
    ]
  ])
}

##############################################################################

##############################################################################
# VPE IP Subnets
##############################################################################

module "vpe_ip_subnets" {
  source           = "../get_subnets"
  for_each         = module.vpe_ip_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = each.value.subnet_name
}

##############################################################################


##############################################################################
# VPE Reserved IP Map
##############################################################################

module "vpe_subnet_reserved_ip_map" {
  source         = "../list_to_map"
  key_name_field = "ip_name"
  list = flatten([
    # For each service
    for service in var.virtual_private_endpoints :
    [
      # For each VPC attached to that service
      for vpcs in service.vpcs :
      [
        # For each subnet where a VPE will be created
        for subnet in vpcs.subnets :
        # Create reserved IP object
        {
          ip_name      = "${vpcs.name}-${service.service_name}-gateway-${subnet}-ip"
          gateway_name = "${vpcs.name}-${service.service_name}"
          id           = module.vpe_ip_subnets["${vpcs.name}-${service.service_name}-gateway-${subnet}-ip"].subnets[0].id
        }
      ]
    ]
  ])
}

##############################################################################

##############################################################################
# VPE outputs
##############################################################################

output "vpe_services" {
  description = "Map of VPE services to be created. Currently only COS is supported."
  value       = module.vpe_service_map.value
}

output "vpe_gateway_map" {
  description = "Map of gateways to be created"
  value       = module.vpe_gateway_map.value
}

output "vpe_subnet_reserved_ip_map" {
  description = "Map of reserved subnet ips for vpes"
  value       = module.vpe_subnet_reserved_ip_map.value
}


##############################################################################