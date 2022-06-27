##############################################################################
# Address Prefixes Tests
##############################################################################

locals {
  assert_address_prefix_0_has_correct_name    = regex("ut-zone-1-1", module.unit_tests.address_prefixes[0].name)
  assert_address_prefix_0_has_correct_address = regex("1", module.unit_tests.address_prefixes[0].cidr)
  assert_address_prefix_0_has_correct_zone    = regex("us-south-1", module.unit_tests.address_prefixes[0].zone)
  assert_address_prefixes_correct_length      = regex("2", tostring(length(module.unit_tests.address_prefixes)))
}

##############################################################################

##############################################################################
# Routes Tests
##############################################################################

locals {
  assert_route_key_exists           = lookup(module.unit_tests.routes, "test-route")
  assert_route_has_correct_next_hop = regex("test", module.unit_tests.routes["test-route"].next_hop)
}

##############################################################################

##############################################################################
# Public Gateway Tests
##############################################################################

locals {
  assert_null_gateways_not_returned = regex("2", tostring(length(keys(module.unit_tests.use_public_gateways))))
  assert_zone_found_in_map          = lookup(module.unit_tests.use_public_gateways, "zone-1")
  assert_zone_correct_name          = regex("us-south-1", module.unit_tests.use_public_gateways["zone-1"])
}

##############################################################################

##############################################################################
# Security Group Rules Test
##############################################################################

locals {
  assert_rule_exists_in_map     = lookup(module.unit_tests.security_group_rules, "test-rule")
  assert_rule_has_correct_field = regex("field", module.unit_tests.security_group_rules["test-rule"].field)
}

##############################################################################

##############################################################################
# Network ACL Tests
##############################################################################

locals {
  assert_acl_exists_in_map                    = lookup(module.unit_tests.acl_map, "acl")
  assert_cluster_rule_exists_in_position_0    = regex("roks-create-worker-nodes-inbound", module.unit_tests.acl_map["acl"].rules[0].name)
  assert_cluster_rule_uses_network_cidr       = regex("1.2.3.4/5", module.unit_tests.acl_map["acl"].rules[0].destination)
  assert_acl_rule_exists_in_last_position     = regex("test-rule", module.unit_tests.acl_map["acl"].rules[length(module.unit_tests.acl_map["acl"].rules) - 1].name)
  assert_length_of_rules_cluster_rules_plus_1 = regex("9", tostring(length(module.unit_tests.acl_map["acl"].rules)))
}

##############################################################################

##############################################################################
# Subnet Tests
##############################################################################

locals {
  assert_subnets_list_0_has_correct_prefix_name                 = regex("ut-subnet-1", module.unit_tests.subnet_list[0].prefix_name)
  assert_subnets_list_0_has_correct_zone                        = regex("1", module.unit_tests.subnet_list[0].zone)
  assert_subnets_list_0_has_correct_zone_name                   = regex("us-south-1", module.unit_tests.subnet_list[0].zone_name)
  assert_subnets_list_0_has_correct_count                       = regex("1", module.unit_tests.subnet_list[0].count)
  assert_subnets_list_0_has_correct_public_gateway              = regex("pgw1", module.unit_tests.subnet_list[0].public_gateway)
  assert_subnets_list_1_has_correct_public_gateway              = regex("null", lookup(module.unit_tests.subnet_list[1], "public_gateway", null) == null ? "null" : "error")
  assert_subnets_list_1_has_correct_count                       = regex("2", module.unit_tests.subnet_list[1].count)
  assert_even_if_gateway_true_no_pgw_provision_zone_return_null = regex("null", lookup(module.unit_tests.subnet_list[2], "public_gateway", null) == null ? "null" : "error")
  assert_subnet_exists_in_map                                   = lookup(module.unit_tests.subnet_map, "ut-subnet-1")
}

##############################################################################