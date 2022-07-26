##############################################################################
# Key Management Type Unit Tests
##############################################################################

locals {
  assert_use_hs_crypto_returns_correct_type    = regex("hs-crypto", module.unit_test_hs_crypto.key_management_type)
  assert_use_kms_data_returns_correct_type     = regex("data", module.unit_test_kms_data.key_management_type)
  assert_use_kms_resource_returns_correct_type = regex("resource", module.unit_test_kms_resource.key_management_type)
  assert_use_hs_crypt_returns_correct_guid     = regex("crypto", module.unit_test_hs_crypto.guid)
  assert_use_kms_data_returns_correct_guid     = regex("data", module.unit_test_kms_data.guid)
  assert_use_kms_resource_returns_correct_guid = regex("resource", module.unit_test_kms_resource.guid)
  assert_use_hs_crypt_returns_correct_crn      = regex("crypto", module.unit_test_hs_crypto.crn)
  assert_use_kms_data_returns_correct_crn      = regex("data", module.unit_test_kms_data.crn)
  assert_use_kms_resource_returns_correct_crn  = regex("resource", module.unit_test_kms_resource.crn)
  assert_key_exists_in_map                     = lookup(module.unit_test_hs_crypto.keys, "test_key")
  assert_key_ring_exists_in_map                = regex("test-ring", module.unit_test_hs_crypto.key_rings[0])
  assert_no_duplicate_key_rings                = regex("1", tostring(length(module.unit_test_hs_crypto.key_rings)))
  assert_key_management_policy_exists          = lookup(module.unit_test_hs_crypto.policies, "test_key")
}

##############################################################################
