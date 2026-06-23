##############################################################################
# Security Group Locals
##############################################################################

locals {
  security_group_map       = module.dynamic_values.security_group_map
  security_group_rules_map = module.dynamic_values.security_group_rules_map
}

##############################################################################


##############################################################################
# Security Group
##############################################################################

resource "ibm_is_security_group" "security_group" {
  for_each       = local.security_group_map
  name           = each.value.name
  resource_group = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  vpc            = each.value.vpc_id
  tags           = var.tags
  access_tags    = each.value.access_tags
}

##############################################################################


##############################################################################
# Security Group Rules
##############################################################################

resource "ibm_is_security_group_rule" "security_group_rules" {
  for_each   = local.security_group_rules_map
  group      = ibm_is_security_group.security_group[each.value.sg_name].id
  direction  = each.value.direction
  remote     = each.value.source
  local      = each.value.local
  ip_version = each.value.ip_version

  protocol = each.value.protocol
  port_min = each.value.port_min
  port_max = each.value.port_max
  type     = each.value.type
  code     = each.value.code

}

##############################################################################
