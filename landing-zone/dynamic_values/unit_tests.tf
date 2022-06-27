##############################################################################
# [Unit Test] Get Subnets
##############################################################################

module "ut_get_subnets" {
  source = "./config_modules/get_subnets"
  subnet_zone_list = [
    {
      name = "ut-vpc-bad-subnet"
    },
    {
      name = "ut-vpc-good-subnet"
    }
  ]
  regex = "ut-vpc-good-subnet"
}

locals {
  assert_get_subnets_correct_name = regex("ut-vpc-good-subnet", module.ut_get_subnets.subnets[0].name)
}

##############################################################################

##############################################################################
# [Unit Test] List to Map if Lookup Value
##############################################################################

module "ut_list_to_map_if_lookup" {
  source = "./config_modules/list_to_map"
  list = [
    {
      name = "test-pass"
      test = true
    },
    {
      name = "test-fail"
    }
  ]
  lookup_field       = "test"
  lookup_value_regex = "^true$"
}

locals {
  ut_list_to_map_if_lookup_assert_one_entry_found = lookup(module.ut_list_to_map_if_lookup.value, "test-pass")
}

##############################################################################

##############################################################################
# [Unit Test] Nested List to Map and Merge
##############################################################################

module "ut_nest_to_map" {
  source = "./config_modules/nested_list_to_map_and_merge"
  list = [
    {
      name = "parent-name"
      test = "test-field"
      children = [
        {
          name = "child-1"
        },
        {
          name = "child-2"
        }
      ]
    }
  ]
  sub_list_name = "children"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "group"
      add_prefix   = "ut"
    },
    {
      parent_field = "test"
      child_key    = "test"
    }
  ]
}

locals {
  actual_netested_map    = module.ut_nest_to_map.value
  assert_2_childen       = regex("child-1;child-2", join(";", keys(local.actual_netested_map)))
  assert_children_groups = regex("ut-parent-name", local.actual_netested_map["child-1"].group)
  assert_children_test   = regex("test-field", local.actual_netested_map["child-2"].test)
}

##############################################################################

##############################################################################
# [Unit Test] Nested List to Map and Merge Prepend From Child
##############################################################################

module "ut_nest_to_map_prepend" {
  source = "./config_modules/nested_list_to_map_and_merge"
  list = [
    {
      name = "parent-name"
      test = "test-field"
      children = [
        {
          name    = "child-1"
          sg_name = "sg"
        },
        {
          name       = "child-2"
          sg_name    = "sg"
          enableHMAC = true
        }
      ]
    }
  ]
  sub_list_name = "children"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "group"
      add_prefix   = "ut"
    },
    {
      parent_field = "test"
      child_key    = "test"
    }
  ]
  add_lookup_child_values = [
    {
      lookup_field_key_name = "parameters"
      lookup_field          = "enableHMAC"
      parse_json_if_true    = "{\"HMAC\" : true}"
    }
  ]
  prepend_parent_key_value_to_child_name = "name"
}

locals {
  actual_add_prefix_netested_map    = module.ut_nest_to_map_prepend.value
  prefix_join                       = join(";", keys(local.actual_add_prefix_netested_map))
  assert_add_prefix_2_childen       = regex("parent-name-child-1;parent-name-child-2", local.prefix_join)
  assert_add_prefix_children_groups = regex("ut-parent-name", local.actual_add_prefix_netested_map["parent-name-child-1"].group)
  assert_add_prefix_children_test   = regex("test-field", local.actual_add_prefix_netested_map["parent-name-child-2"].test)
  assert_child_2_has_parameters     = regex("true", local.actual_add_prefix_netested_map["parent-name-child-2"].parameters.HMAC)
}

##############################################################################

##############################################################################
# [Unit Test] List to map value no replace
##############################################################################

module "ut_list_to_map_value_no_replace" {
  source = "./config_modules/list_to_map_value"
  list = [
    {
      name = "test"
      id   = "testid123"
    }
  ]
  value_key_name = "id"
}

locals {
  assert_list_to_map_no_replace_value_correct = regex("testid123", module.ut_list_to_map_value_no_replace.value["test"])
}

##############################################################################

##############################################################################
# [Unit Test] List to map value replace
##############################################################################

module "ut_list_to_map_value_replace" {
  source = "./config_modules/list_to_map_value"
  list = [
    {
      name = "test"
      id   = "1"
    }
  ]
  value_key_name = "id"
  key_replace_value = {
    find    = "es"
    replace = "AAAA"
  }
}

locals {
  assert_list_to_map_replace_value_correct = regex("1", module.ut_list_to_map_value_replace.value["tAAAAt"])
}

##############################################################################