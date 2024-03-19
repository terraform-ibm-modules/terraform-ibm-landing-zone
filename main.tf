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


##############################################################################
# Create CBR prewired rules for VPC -> COS (scoped to resource group)
##############################################################################
module "slz_cbr_zone_vpcs" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.18.0"
  name             = "${var.prefix}-slz-vpcs-zone"
  zone_description = "Single zone grouping all SLZ VPCs."
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [
    for network in module.vpc :
    { "type" = "vpc", value = network.vpc_crn }
  ]
}

locals {

  cos_data_merge_maps = merge(local.cos_data_map, local.cos_map)

  cos_resource_group_names = distinct(flatten([
    for key, value in local.cos_data_merge_maps : [
      value.resource_group
    ]
  ]))

  rule_contexts = [{
    attributes = [
      {
        "name" : "endpointType",
        "value" : "private"
      },
      {
        name  = "networkZoneId"
        value = module.slz_cbr_zone_vpcs["zone_id"]
    }]
  }]

  target_service_details = [
    for cos_rg_name in local.cos_resource_group_names :
    {
      target_service_name = "cloud-object-storage",
      target_rg           = local.resource_groups[cos_rg_name]
      tags                = var.tags
    }
  ]
}

module "vpc_to_cos_cbr_rule" {
  count            = length(local.cos_resource_group_names)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.18.0"
  rule_description = "${var.prefix}-${local.target_service_details[count.index].target_service_name}-rg-scoped-slz-rule"
  enforcement_mode = var.enforcement_mode
  rule_contexts    = local.rule_contexts
  operations = [{
    api_types = [{
      api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
    }]
  }]

  resources = [{
    tags = local.target_service_details[count.index].tags != null ? [for tag in local.target_service_details[count.index].tags : {
      name  = split(":", tag)[0]
      value = split(":", tag)[1]
    }] : []
    attributes = local.target_service_details[count.index].target_rg != null ? [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "resourceGroupId",
        operator = "stringEquals",
        value    = local.target_service_details[count.index].target_rg
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = local.target_service_details[count.index].target_service_name
      }] : [
      {
        name     = "accountId",
        operator = "stringEquals",
        value    = data.ibm_iam_account_settings.iam_account_settings.account_id
      },
      {
        name     = "serviceName",
        operator = "stringEquals",
        value    = local.target_service_details[count.index].target_service_name
    }]
  }]
}

##############################################################################
