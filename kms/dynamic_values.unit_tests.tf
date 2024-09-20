##############################################################################
# Key Management Type Unit Tests
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  assert_use_hs_crypto_returns_correct_type = regex("hs-crypto", module.unit_test_hs_crypto.key_management_type)
  # tflint-ignore: terraform_unused_declarations
  assert_use_kms_data_returns_correct_type = regex("data", module.unit_test_kms_data.key_management_type)
  # tflint-ignore: terraform_unused_declarations
  assert_use_kms_resource_returns_correct_type = regex("resource", module.unit_test_kms_resource.key_management_type)
  # tflint-ignore: terraform_unused_declarations
  assert_use_hs_crypt_returns_correct_guid = regex("crypto", module.unit_test_hs_crypto.guid)
  # tflint-ignore: terraform_unused_declarations
  assert_use_kms_data_returns_correct_guid = regex("data", module.unit_test_kms_data.guid)
  # tflint-ignore: terraform_unused_declarations
  assert_use_kms_resource_returns_correct_guid = regex("resource", module.unit_test_kms_resource.guid)
  # tflint-ignore: terraform_unused_declarations
  assert_use_hs_crypt_returns_correct_crn = regex("crypto", module.unit_test_hs_crypto.crn)
  # tflint-ignore: terraform_unused_declarations
  assert_use_kms_data_returns_correct_crn = regex("data", module.unit_test_kms_data.crn)
  # tflint-ignore: terraform_unused_declarations
  assert_use_kms_resource_returns_correct_crn = regex("resource", module.unit_test_kms_resource.crn)
  # tflint-ignore: terraform_unused_declarations
  assert_key_exists_in_map = module.unit_test_hs_crypto.keys["test_key"]
  # tflint-ignore: terraform_unused_declarations
  assert_key_ring_exists_in_map = regex("test-ring", module.unit_test_hs_crypto.key_rings[0].key_ring_name)
  # tflint-ignore: terraform_unused_declarations
  assert_no_duplicate_key_rings = regex("1", tostring(length(module.unit_test_hs_crypto.key_rings)))
  # tflint-ignore: terraform_unused_declarations
  assert_key_management_policy_exists = module.unit_test_hs_crypto.policies["test_key"]
}

##############################################################################
