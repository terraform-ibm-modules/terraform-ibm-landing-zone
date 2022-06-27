##############################################################################
# Access Group Locals
##############################################################################

module "access_group_object" {
  source = "./config_modules/list_to_map"
  list   = var.access_groups
  prefix = var.prefix
}

##############################################################################

##############################################################################
# Map of Access Policies
##############################################################################

module "access_policies" {
  source        = "./config_modules/nested_list_to_map_and_merge"
  list          = var.access_groups
  sub_list_name = "policies"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "group"
      add_prefix   = var.prefix
    }
  ]
}

##############################################################################

##############################################################################
# Map of Dynamic Rules
##############################################################################

module "dynamic_rules" {
  source        = "./config_modules/nested_list_to_map_and_merge"
  list          = var.access_groups
  sub_list_name = "dynamic_policies"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "group"
      add_prefix   = var.prefix
    }
  ]
}

##############################################################################

##############################################################################
# Account Management Map
##############################################################################

module "account_management_map" {
  source = "./config_modules/list_to_map_value"
  list = [
    for group in var.access_groups :
    {
      group = "${var.prefix}-${group.name}"
      roles = group.account_management_policies
    } if lookup(group, "account_management_policies", null) != null
  ]
  key_name_field = "group"
  value_key_name = "roles"
}

##############################################################################

##############################################################################
# Access Group With Invites Map
##############################################################################

module "access_groups_with_invites_map" {
  source             = "./config_modules/list_to_map"
  list               = var.access_groups
  lookup_field       = "invite_users"
  lookup_value_regex = "^true$"
  prefix             = var.prefix
}

##############################################################################