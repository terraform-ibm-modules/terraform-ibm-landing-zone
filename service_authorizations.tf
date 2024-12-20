##############################################################################
# Service To Service Authorization Policies
# > `target_resource_group_id` and `target_resource_instance_id` are mutually
#    exclusive. IAM will use the least specific of the two
##############################################################################

locals {
  authorization_policies = module.dynamic_values.service_authorizations
}

##############################################################################


##############################################################################
# Authorization Policies
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  for_each                    = var.skip_all_s2s_auth_policies == true ? null : local.authorization_policies
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

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_authorization_policy" {
  depends_on = [ibm_iam_authorization_policy.policy]

  create_duration = "30s"
}

##############################################################################
