##############################################################################
# Object Storage Dynamic Values
##############################################################################

module "cos" {
  source            = "./config_modules/cos"
  prefix            = var.prefix
  cos               = var.cos
  cos_data_source   = var.cos_data_source
  cos_resource      = var.cos_resource
  cos_resource_keys = var.cos_resource_keys
  suffix = length([
    for instance in var.cos :
    instance if lookup(instance, "random_suffix", null) == true
  ]) > 0 ? var.suffix : ""
}

locals {
  cos_instance_ids = module.cos.cos_instance_ids
}

##############################################################################

##############################################################################
# [Unit Test] COS Bucket To Instance Map
##############################################################################

module "ut_cos" {
  source = "./config_modules/cos"
  prefix = "ut"
  cos_data_source = {
    data-cos = {
      name = "data-cos"
      id   = ":::::::5678"
    }
  }
  cos_resource = {
    test-cos = {
      name = "ut-test-cos"
      id   = ":::::::1234"
    }
  }
  cos_resource_keys = {
    data-bucket-key = {
      credentials = {
        apikey = "1234"
      }
    }
  }
  cos = [
    {
      name     = "data-cos"
      use_data = true
      buckets = [
        {
          name = "data-bucket"
        }
      ]
      keys = [
        {
          name        = "data-bucket-key"
          enable_HMAC = false
        },
        {
          name        = "teleport-key"
          enable_HMAC = true
        }
      ]
    },
    {
      name     = "test-cos"
      use_data = false
      buckets = [
        {
          name = "create-bucket"
        }
      ]
    }
  ]
}

locals {
  assert_bucket_contains_correct_api_key = regex("1234", module.ut_cos.bucket_to_instance_map["data-bucket"].bind_key)
}

##############################################################################

##############################################################################
# [Unit Test] COS With Suffix
##############################################################################

module "ut_cos_with_suffix" {
  source = "./config_modules/cos"
  prefix = "ut"
  cos_data_source = {
    data-cos = {
      name = "data-cos"
      id   = ":::::::5678"
    }
  }
  cos_resource = {
    test-cos = {
      name = "ut-test-cos-XXXX"
      id   = ":::::::1234"
    }
  }
  cos_resource_keys = {
    data-bucket-key = {
      credentials = {
        apikey = "1234"
      }
    }
  }
  suffix = "XXXX"
  cos = [
    {
      name     = "data-cos"
      use_data = true
      buckets = [
        {
          name = "data-bucket"
        }
      ]
      keys = [
        {
          name        = "data-bucket-key"
          enable_HMAC = false
        },
        {
          name        = "teleport-key"
          enable_HMAC = true
        }
      ]
      random_suffix = true
    },
    {
      name     = "test-cos"
      use_data = false
      buckets = [
        {
          name = "create-bucket"
        }
      ]
      random_suffix = true
    }
  ]
}

locals {
  cos_instance_key_in_ids_with_suffix_replaced = lookup(module.ut_cos_with_suffix.cos_instance_ids, "test-cos")
  cos_bucket_has_random_suffix                 = regex("true", tostring(module.ut_cos_with_suffix.cos_bucket_map["data-bucket"].random_suffix))
  cos_key_has_random_suffix                    = regex("true", tostring(module.ut_cos_with_suffix.cos_key_map["data-bucket-key"].random_suffix))
}

##############################################################################