##############################################################################
# Create VPCs
##############################################################################

locals {
  vpc_map = module.dynamic_values.vpc_map
}

module "vpc" {
  source                                 = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version                                = "7.13.2"
  for_each                               = local.vpc_map
  depends_on                             = [ibm_iam_authorization_policy.policy]
  name                                   = each.value.prefix
  existing_vpc_id                        = each.value.existing_vpc_id
  create_vpc                             = each.value.existing_vpc_id == null ? true : false
  tags                                   = var.tags
  access_tags                            = each.value.access_tags
  resource_group_id                      = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  region                                 = var.region
  prefix                                 = var.prefix
  network_cidrs                          = [var.network_cidr]
  classic_access                         = each.value.classic_access
  default_network_acl_name               = each.value.default_network_acl_name
  default_security_group_name            = each.value.default_security_group_name
  security_group_rules                   = each.value.default_security_group_rules == null ? [] : each.value.default_security_group_rules
  default_routing_table_name             = each.value.default_routing_table_name
  address_prefixes                       = each.value.address_prefixes
  network_acls                           = each.value.network_acls
  use_public_gateways                    = each.value.use_public_gateways
  create_subnets                         = length(coalesce(each.value.existing_subnet_ids, [])) == 0 ? true : false
  subnets                                = length(coalesce(each.value.existing_subnet_ids, [])) == 0 ? each.value.subnets : { "zone-1" : [], "zone-2" : [], "zone-3" : [] }
  existing_subnet_ids                    = each.value.existing_subnet_ids
  enable_vpc_flow_logs                   = (each.value.flow_logs_bucket_name != null) ? true : false
  create_authorization_policy_vpc_to_cos = false
  existing_storage_bucket_name           = (each.value.flow_logs_bucket_name != null) ? ibm_cos_bucket.buckets[each.value.flow_logs_bucket_name].bucket_name : null
  clean_default_sg_acl                   = (each.value.clean_default_sg_acl == null) ? false : each.value.clean_default_sg_acl
}


##############################################################################
