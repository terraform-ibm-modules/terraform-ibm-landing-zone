##############################################################################
# VPE Locals
##############################################################################

locals {
  vpe_gateway_map = module.dynamic_values.vpe_gateway_map
  reserved_ip_map = module.dynamic_values.vpe_subnet_reserved_ip_map
}

##############################################################################


##############################################################################
# Endpoint Gateways
##############################################################################

resource "ibm_is_subnet_reserved_ip" "ip" {
  for_each = local.reserved_ip_map
  subnet   = each.value.id
}

resource "ibm_is_virtual_endpoint_gateway" "endpoint_gateway" {
  for_each        = local.vpe_gateway_map
  name            = "${var.prefix}-${each.key}"
  vpc             = each.value.vpc_id
  resource_group  = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  security_groups = each.value.security_group_name == null ? null : [ibm_is_security_group.security_group[each.value.security_group_name].id]
  tags            = var.tags
  access_tags     = each.value.access_tags

  target {
    crn           = each.value.crn
    resource_type = "provider_cloud_service"
  }

  depends_on = [time_sleep.wait_30_seconds]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [ibm_is_security_group.security_group]

  destroy_duration = "30s"
}

resource "ibm_is_virtual_endpoint_gateway_ip" "endpoint_gateway_ip" {
  for_each    = local.reserved_ip_map
  gateway     = ibm_is_virtual_endpoint_gateway.endpoint_gateway[each.value.gateway_name].id
  reserved_ip = ibm_is_subnet_reserved_ip.ip[each.key].reserved_ip
}

##############################################################################\
