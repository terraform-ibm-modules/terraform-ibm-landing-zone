##############################################################################
# Create VPCs
##############################################################################

locals {
  vpc_map = module.dynamic_values.vpc_map
}

# VPC module explicit dependencies (using 'depends_on') have been removed.
# The 'depends_on' option was causing VPC module data blocks to not gather data for existing VPC or subnets during plan time,
# which was causing issues with other modules in LZ.
# Due to existing implicit dependencies we do not think this will be an issue, including auth policies for activity tracker.
module "vpc" {
  source                      = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version                     = "7.17.1"
  for_each                    = local.vpc_map
  name                        = each.value.prefix
  existing_vpc_id             = each.value.existing_vpc_id
  create_vpc                  = each.value.existing_vpc_id == null ? true : false
  tags                        = var.tags
  access_tags                 = each.value.access_tags
  resource_group_id           = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  region                      = var.region
  prefix                      = var.prefix
  network_cidrs               = [var.network_cidr]
  classic_access              = each.value.classic_access
  default_network_acl_name    = each.value.default_network_acl_name
  default_security_group_name = each.value.default_security_group_name
  security_group_rules        = each.value.default_security_group_rules == null ? [] : each.value.default_security_group_rules
  default_routing_table_name  = each.value.default_routing_table_name
  address_prefixes            = each.value.address_prefixes
  network_acls                = each.value.network_acls
  use_public_gateways         = each.value.use_public_gateways
  create_subnets              = length(coalesce(each.value.existing_subnets, [])) == 0 ? true : false
  # NOTE: for existing subnets scenario, current VPC module does not accept null for subnets map, so sending in a map with empty arrays instead
  subnets                                = length(coalesce(each.value.existing_subnets, [])) == 0 ? each.value.subnets : { "zone-1" : [], "zone-2" : [], "zone-3" : [] }
  existing_subnets                       = each.value.existing_subnets
  enable_vpc_flow_logs                   = (each.value.flow_logs_bucket_name != null) ? true : false
  create_authorization_policy_vpc_to_cos = false
  existing_storage_bucket_name           = (each.value.flow_logs_bucket_name != null) ? ibm_cos_bucket.buckets[each.value.flow_logs_bucket_name].bucket_name : null
  clean_default_sg_acl                   = (each.value.clean_default_sg_acl == null) ? false : each.value.clean_default_sg_acl
}


##############################################################################
