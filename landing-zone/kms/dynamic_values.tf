##############################################################################
# Dynamic Values for Module
##############################################################################

module "dynamic_values" {
  source        = "./dynamic_values"
  use_hs_crypto = var.key_management.use_hs_crypto
  use_data      = var.key_management.use_data
  hpcs_data     = data.ibm_resource_instance.hpcs_instance
  kms_data      = data.ibm_resource_instance.kms
  kms_resource  = ibm_resource_instance.kms
  keys          = var.keys
}

##############################################################################

##############################################################################
# Dynamic Modules For Unit Tests
##############################################################################

module "unit_test_hs_crypto" {
  source        = "./dynamic_values"
  use_hs_crypto = true
  hpcs_data = [{
    guid = "crypto"
    crn  = "crypto"
  }]
  kms_data     = []
  kms_resource = []
  keys = [
    {
      name     = "test_key"
      key_ring = "test-ring"
      policies = {
        rotation = {
          interval_month = 1
        }
      }
    },
    {
      name     = "test_key_2"
      key_ring = "test-ring"
    }
  ]
}

module "unit_test_kms_data" {
  source    = "./dynamic_values"
  use_data  = true
  hpcs_data = []
  kms_data = [{
    guid = "data"
    crn  = "data"
  }]
  kms_resource = []
}

module "unit_test_kms_resource" {
  source    = "./dynamic_values"
  hpcs_data = []
  kms_data  = []
  kms_resource = [{
    guid = "resource"
    crn  = "resource"
  }]
}

##############################################################################