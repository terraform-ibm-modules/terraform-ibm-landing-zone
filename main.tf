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

# output "vpc_sample" {
#   value = local.vpc_map
# }

locals {
  vpc_subnets_map = {
    management_subnets = flatten([
      for zone, subnet_list in local.vpc_map["management"]["subnets"] : [
        for subnet in subnet_list : {
          name = subnet["name"]
          cidr = subnet["cidr"]
          acl_name = subnet["acl_name"]
        }
      ]
    ])

    workload_subnets = flatten([
      for zone, subnet_list in local.vpc_map["workload"]["subnets"] : [
        for subnet in subnet_list : {
          name = subnet["name"]
          cidr = subnet["cidr"]
          acl_name = subnet["acl_name"]
        }
      ]
    ])
  }

# subnets_map = {
#     management_subnets = {
#       for idx, subnet in local.management_subnets : subnet["name"] => subnet
#     }
#     workload_subnets = {
#       for idx, subnet in local.workload_subnets : subnet["name"] => subnet
#     }
#   }

# workload_cidrs = flatten([
#     for subnet_map_key, subnet_map in local.subnets_map : [
#       for subnet_key, subnet in subnet_map : subnet["cidr"]
#     ]
#   ])


# vpc_subnets = flatten([
#     for subnet_type, subnets in local.vpc_subnets_map : [
#       for subnet in subnets : {
#         type        = subnet_type
#         acl_name    = subnet["acl_name"]
#         cidr        = subnet["cidr"]
#         name        = subnet["name"]
#       }
#     ]
#   ])


  slz_vpc_zone_list = (length(local.vpc_subnets_map) > 0) ? [
    for  subnet_type, subnets in local.vpc_subnets_map : 
       {
      name             = "${var.prefix}-${subnet_type}-cbr-slz-zone"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      zone_description = "${subnet_type}-cbr-slz-zone"
      addresses = [for subnet in subnets :
        {
          type = "subnet"
          value= subnet["cidr"]
        }
      ]
  }] : []


}

module "slz_vpcs_zone_subnets" {
  count            = length(local.slz_vpc_zone_list)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version           = "1.18.0"
  name             = local.slz_vpc_zone_list[count.index].name
  zone_description = local.slz_vpc_zone_list[count.index].zone_description
  account_id       = local.slz_vpc_zone_list[count.index].account_id
  addresses        = local.slz_vpc_zone_list[count.index].addresses
}


# output "management_subnets" {
#   value = local.management_subnets
# }

output "workload_subnets" {
  value = local.vpc_subnets_map
}

##############################################################################



# module "slz_management_zone_subnets" {
#   source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
#   version           = "1.18.0"
#   name             = "${var.prefix}-List of management zones subnets"
#   account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
#   zone_description = "Zone grouping list of management zones subnets"
#       addresses = [
#       for cidrs in local.management_subnets :
#       { "type" = "subnet", value = cidrs["cidr"] }
#     ]
# }


# module "slz_workload_zone_subnets" {
#   source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
#   version           = "1.18.0"
#   name             = "${var.prefix}-List of workload zones subnets"
#   account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
#   zone_description = "Zone grouping list of workload zones subnets"
#       addresses = [
#       for cidrs in local.workload_subnets :
#       { "type" = "subnet", value = cidrs["cidr"] }
#     ]
# }


##############################################################################
# Create CBR prewired rules
##############################################################################

# locals {
#     vpc_zone_list = [{
#     name             = "${var.prefix}-slz-vpc-zone"
#     account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
#     zone_description = "${var.prefix}-slz-vpc-zone"
#     addresses = [
#       for network in module.vpc :
#       { "type" = "vpc", value = network.vpc_crn }
#     ]
#   }]

# }


# module "slz_cbr_zone" {
#   count            = length(local.vpc_zone_list)
#   source            = "terraform-ibm-modules/cbr/ibm//modules/fscloud"
#   version           = "1.18.0"
#   name             = local.zone_list[count.index].name
#   zone_description = local.zone_list[count.index].zone_description
#   account_id       = local.zone_list[count.index].account_id
#   addresses        = local.zone_list[count.index].addresses
# }

##############################################################################