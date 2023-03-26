##############################################################################
# Create VPCs
##############################################################################

locals {
  vpc_map       = module.dynamic_values.vpc_map
  flow_logs_map = module.dynamic_values.flow_logs_map
}

module "vpc" {
  source                      = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git?ref=v4.0.0"
  for_each                    = local.vpc_map
  name                        = each.value.prefix
  tags                        = var.tags
  resource_group_id           = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  region                      = var.region
  prefix                      = var.prefix
  network_cidr                = var.network_cidr
  classic_access              = each.value.classic_access
  use_manual_address_prefixes = each.value.use_manual_address_prefixes
  default_network_acl_name    = each.value.default_network_acl_name
  default_security_group_name = each.value.default_security_group_name
  security_group_rules        = each.value.default_security_group_rules == null ? [] : each.value.default_security_group_rules
  default_routing_table_name  = each.value.default_routing_table_name
  address_prefixes            = each.value.address_prefixes
  network_acls                = each.value.network_acls
  use_public_gateways         = each.value.use_public_gateways
  subnets                     = each.value.subnets
}


##############################################################################


##############################################################################
# Add VPC to Flow Logs
##############################################################################

resource "ibm_is_flow_log" "flow_logs" {
  for_each       = local.flow_logs_map
  name           = "${each.key}-logs"
  target         = each.value.vpc_id
  active         = true
  storage_bucket = ibm_cos_bucket.buckets[each.value.bucket].bucket_name
  resource_group = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  tags           = var.tags

  depends_on = [ibm_cos_bucket.buckets, ibm_iam_authorization_policy.policy]
}

##############################################################################
