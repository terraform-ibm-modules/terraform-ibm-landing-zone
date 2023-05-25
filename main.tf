##############################################################################
# Create VPCs
##############################################################################

locals {
  vpc_map = module.dynamic_values.vpc_map
}

module "vpc" {
  source                                 = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git?ref=v7.2.0"
  for_each                               = local.vpc_map
  name                                   = each.value.prefix
  tags                                   = var.tags
  access_tags                            = var.access_tags
  resource_group_id                      = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  region                                 = var.region
  prefix                                 = var.prefix
  network_cidrs                          = var.network_cidrs
  classic_access                         = each.value.classic_access
  default_network_acl_name               = each.value.default_network_acl_name
  default_security_group_name            = each.value.default_security_group_name
  security_group_rules                   = each.value.default_security_group_rules == null ? [] : each.value.default_security_group_rules
  default_routing_table_name             = each.value.default_routing_table_name
  address_prefixes                       = each.value.address_prefixes
  network_acls                           = each.value.network_acls
  use_public_gateways                    = each.value.use_public_gateways
  subnets                                = each.value.subnets
  enable_vpc_flow_logs                   = (each.value.flow_logs_bucket_name != null) ? true : false
  create_authorization_policy_vpc_to_cos = false
  existing_storage_bucket_name           = (each.value.flow_logs_bucket_name != null) ? ibm_cos_bucket.buckets[each.value.flow_logs_bucket_name].bucket_name : null
  depends_on                             = [ibm_iam_authorization_policy.policy]
  ibmcloud_api_key                       = var.ibmcloud_api_key
  clean_default_security_group           = (each.value.clean_default_security_group == null) ? false : each.value.clean_default_security_group
  clean_default_acl                      = (each.value.clean_default_acl == null) ? false : each.value.clean_default_acl
}


##############################################################################
