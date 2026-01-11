##############################################################################
# Create VPCs
##############################################################################

data "ibm_is_vpc" "vpc" {
  for_each   = module.vpc
  identifier = each.value.vpc_id
  depends_on = [time_sleep.wait_for_vpc_creation_data]
}

resource "time_sleep" "wait_for_vpc_creation_data" {
  depends_on = [
    resource.ibm_is_security_group.security_group,
    resource.ibm_is_security_group_rule.security_group_rules,
    resource.ibm_container_vpc_cluster.cluster,
    resource.ibm_container_vpc_worker_pool.pool,
    resource.ibm_is_virtual_endpoint_gateway.endpoint_gateway,
    resource.ibm_tg_connection.connection,
    module.f5_vsi,
    module.vsi,
    module.vpc
  ]
  create_duration = "30s"
}

locals {
  vpc_map = module.dynamic_values.vpc_map
}

# VPC module explicit dependencies (using 'depends_on') have been removed.
# The 'depends_on' option was causing VPC module data blocks to not gather data for existing VPC or subnets during plan time,
# which was causing issues with other modules in LZ.
# Due to existing implicit dependencies we do not think this will be an issue, including auth policies for activity tracker.
module "vpc" {
  source                      = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version                     = "8.10.6"
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
  existing_storage_bucket_name           = (each.value.flow_logs_bucket_name != null) ? time_sleep.wait_for_authorization_policy_buckets[each.value.flow_logs_bucket_name].triggers["bucket_name"] : null
  clean_default_sg_acl                   = (each.value.clean_default_sg_acl == null) ? false : each.value.clean_default_sg_acl
  dns_binding_name                       = each.value.dns_binding_name
  dns_instance_name                      = each.value.dns_instance_name
  dns_custom_resolver_name               = each.value.dns_custom_resolver_name
  dns_location                           = each.value.dns_location
  dns_plan                               = each.value.dns_plan
  dns_zones                              = each.value.dns_zones
  dns_records                            = each.value.dns_records
  existing_dns_instance_id               = each.value.existing_dns_instance_id
  use_existing_dns_instance              = each.value.use_existing_dns_instance
  enable_hub                             = each.value.enable_hub
  skip_spoke_auth_policy                 = each.value.skip_spoke_auth_policy
  hub_account_id                         = each.value.hub_account_id
  enable_hub_vpc_id                      = each.value.enable_hub_vpc_id
  hub_vpc_id                             = each.value.hub_vpc_id
  enable_hub_vpc_crn                     = each.value.enable_hub_vpc_crn
  hub_vpc_crn                            = each.value.hub_vpc_crn
  update_delegated_resolver              = each.value.update_delegated_resolver
  skip_custom_resolver_hub_creation      = each.value.skip_custom_resolver_hub_creation
  resolver_type                          = each.value.resolver_type
  manual_servers                         = each.value.manual_servers
}


##############################################################################
