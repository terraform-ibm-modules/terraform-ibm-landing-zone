##############################################################################
# Service To Service Authorization Policies
# > `target_resource_group_id` and `target_resource_instance_id` are mutually
#    exclusive. IAM will use the least specific of the two
##############################################################################

locals {
  authorization_policies_no_buckets = {
    for auth_key, auth_value in module.dynamic_values.service_authorizations : auth_key => auth_value
    if !var.skip_all_s2s_auth_policies && auth_value.target_resource_type != "bucket"
  }

  authorization_policies_only_buckets = {
    for auth_key, auth_value in module.dynamic_values.service_authorizations : auth_key => auth_value
    if !var.skip_all_s2s_auth_policies && auth_value.target_resource_type == "bucket"
  }
}

##############################################################################


##############################################################################
# Authorization Policies
# DEV NOTE:
# The policy creations need to be split into multiple blocks due to dependencies,
# for instance key policies are needed to create buckets, so must be separated
# from each other to avoid plan cycle errors.
##############################################################################

# handle non-bucket policies
resource "ibm_iam_authorization_policy" "policy" {
  for_each                    = local.authorization_policies_no_buckets
  source_service_name         = each.value.source_service_name
  source_resource_type        = lookup(each.value, "source_resource_type", null)
  source_resource_instance_id = lookup(each.value, "source_resource_instance_id", null)
  source_resource_group_id    = lookup(each.value, "source_resource_group_id", null)
  roles                       = each.value.roles
  description                 = each.value.description

  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = coalesce(each.value.target_resource_account_id, data.ibm_iam_account_settings.iam_account_settings.account_id)
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_service_name", null) != null ? [1] : []
    content {
      name     = "serviceName"
      operator = "stringEquals"
      value    = each.value.target_service_name
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_instance_id", null) != null ? [1] : []
    content {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = each.value.target_resource_instance_id
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_group", null) != null ? [1] : []
    content {
      name     = "resourceGroupId"
      operator = "stringEquals"
      value    = each.value.target_resource_group
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_type", null) != null ? [1] : []
    content {
      name     = "resourceType"
      operator = "stringEquals"
      value    = each.value.target_resource_type
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_id", null) != null ? [1] : []
    content {
      name     = "resource"
      operator = "stringEquals"
      value    = each.value.target_resource_id
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# handle bucket policies
resource "ibm_iam_authorization_policy" "cos_bucket_policy" {
  for_each                    = local.authorization_policies_only_buckets
  source_service_name         = each.value.source_service_name
  source_resource_type        = lookup(each.value, "source_resource_type", null)
  source_resource_instance_id = lookup(each.value, "source_resource_instance_id", null)
  source_resource_group_id    = lookup(each.value, "source_resource_group_id", null)
  roles                       = each.value.roles
  description                 = each.value.description

  # NOTE: the `target_resource_id` from dynamic_values contains the key name of the bucket,
  #       which is then looked up for its CRN inside this resource block (this avoids plan cycle issues)
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = trimprefix(split(":", ibm_cos_bucket.buckets[each.value.target_resource_id].crn)[6], "a/")
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_service_name", null) != null ? [1] : []
    content {
      name     = "serviceName"
      operator = "stringEquals"
      value    = each.value.target_service_name
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_instance_id", null) != null ? [1] : []
    content {
      name     = "serviceInstance"
      operator = "stringEquals"
      value    = split(":", ibm_cos_bucket.buckets[each.value.target_resource_id].crn)[7]
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_group", null) != null ? [1] : []
    content {
      name     = "resourceGroupId"
      operator = "stringEquals"
      value    = each.value.target_resource_group
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_type", null) != null ? [1] : []
    content {
      name     = "resourceType"
      operator = "stringEquals"
      value    = each.value.target_resource_type
    }
  }

  dynamic "resource_attributes" {
    for_each = lookup(each.value, "target_resource_id", null) != null ? [1] : []
    content {
      name     = "resource"
      operator = "stringEquals"
      value    = split(":", ibm_cos_bucket.buckets[each.value.target_resource_id].crn)[9]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.policy]

  create_duration = "30s"
}

resource "time_sleep" "wait_for_authorization_policy_buckets" {
  depends_on = [ibm_iam_authorization_policy.cos_bucket_policy]

  create_duration = "30s"
}

##############################################################################
