##############################################################################
# Account Settings
##############################################################################

resource "ibm_iam_account_settings" "iam_account_settings" {
  count                           = var.iam_account_settings.enable ? 1 : 0
  mfa                             = var.iam_account_settings.mfa
  allowed_ip_addresses            = var.iam_account_settings.allowed_ip_addresses
  include_history                 = var.iam_account_settings.include_history
  if_match                        = var.iam_account_settings.if_match
  max_sessions_per_identity       = var.iam_account_settings.max_sessions_per_identity
  restrict_create_service_id      = var.iam_account_settings.restrict_create_service_id
  restrict_create_platform_apikey = var.iam_account_settings.restrict_create_platform_apikey
  session_expiration_in_seconds   = var.iam_account_settings.session_expiration_in_seconds
  session_invalidation_in_seconds = var.iam_account_settings.session_invalidation_in_seconds
}

##############################################################################

##############################################################################
# Local Variables
##############################################################################

locals {
  access_groups_object       = module.dynamic_values.access_groups_object
  access_policies            = module.dynamic_values.access_policies
  dynamic_rules              = module.dynamic_values.dynamic_rules
  account_management_map     = module.dynamic_values.account_management_map
  access_groups_with_invites = module.dynamic_values.access_groups_with_invites
}

##############################################################################


##############################################################################
# Create IAM Access Groups
##############################################################################

resource "ibm_iam_access_group" "groups" {
  for_each    = local.access_groups_object
  name        = each.key
  description = each.value.description
  tags        = var.tags
}

##############################################################################

##############################################################################
# Create Access Group Policies
##############################################################################

resource "ibm_iam_access_group_policy" "policies" {
  for_each        = local.access_policies
  access_group_id = ibm_iam_access_group.groups[each.value.group].id
  roles           = each.value.roles
  resources {
    # Resources are made variable so that each policy can be specific without needing to use multiple blocks
    resource_group_id    = each.value.resources.resource_group != null ? local.resource_groups[each.value.resources.resource_group] : null
    resource_type        = each.value.resources.resource_type
    service              = each.value.resources.service
    resource_instance_id = each.value.resources.resource_instance_id
    resource             = each.value.resources.resource
  }
}

##############################################################################


##############################################################################
# Create Dynamic Access Group Rules
##############################################################################

resource "ibm_iam_access_group_dynamic_rule" "dynamic_rules" {
  for_each          = local.dynamic_rules
  name              = "${var.prefix}-${each.value.name}"
  access_group_id   = ibm_iam_access_group.groups[each.value.group].id
  expiration        = each.value.expiration
  identity_provider = each.value.identity_provider
  conditions {
    claim    = each.value.conditions.claim
    operator = each.value.conditions.operator
    value    = each.value.conditions.value
  }
}

##############################################################################


##############################################################################
# Create Account Management Policies (Optional)
# - This is done separately so that the `resource` block in the `policies`
#   resources will continue to work
##############################################################################

resource "ibm_iam_access_group_policy" "account_management_policies" {
  for_each           = local.account_management_map
  access_group_id    = ibm_iam_access_group.groups[each.key].id
  account_management = true
  roles              = each.value
}

##############################################################################


##############################################################################
# Add users to access group after invite
##############################################################################

resource "ibm_iam_access_group_members" "group_members" {
  for_each        = local.access_groups_with_invites
  access_group_id = ibm_iam_access_group.groups[each.key].id
  ibm_ids         = each.value.invite_users
}

##############################################################################
