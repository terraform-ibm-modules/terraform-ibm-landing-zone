##############################################################################
# VPC Placement Groups
##############################################################################

module "placement_group_map" {
  source = "./dynamic_values/config_modules/list_to_map"
  list   = var.vpc_placement_groups
}

resource "ibm_is_placement_group" "placement_group" {
  for_each       = module.placement_group_map.value
  access_tags    = each.value.access_tags
  name           = "${var.prefix}-${each.value.name}"
  resource_group = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  strategy       = each.value.strategy
  tags           = var.tags
}

##############################################################################
