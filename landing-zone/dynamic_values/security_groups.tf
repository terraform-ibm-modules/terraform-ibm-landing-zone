##############################################################################
# Security Group Dynamic Values
##############################################################################

module "security_group_map" {
  source = "./config_modules/list_to_map"
  list = [
    for group in var.security_groups :
    merge(group, { vpc_id = var.vpc_modules[group.vpc_name].vpc_id })
  ]
}

##############################################################################

##############################################################################
# Security Group Rules Map
##############################################################################

module "security_group_rules_map" {
  source        = "./config_modules/nested_list_to_map_and_merge"
  list          = var.security_groups
  sub_list_name = "rules"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "sg_name"
    }
  ]
  prepend_parent_key_value_to_child_name = "name"
}

##############################################################################