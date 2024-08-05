##############################################################################
# Create CBR zone for all VPCs 
##############################################################################

# Allow schematics, from outside VPC, to manage resources
module "cbr_zone_schematics" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.20.0"
  name             = "${var.prefix}-schematics-landing-zone"
  zone_description = "CBR Network zone containing Schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}

module "cbr_zone_vpcs" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.20.0"
  name             = "${var.prefix}-landing-zone-vpcs-zone"
  zone_description = "Single zone grouping all landing zone VPCs."
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
        value = module.cbr_zone_vpcs.zone_id
    }]
    attributes = [
      {
        "name" : "endpointType",
        "value" : "private"
      },
      {
        name  = "networkZoneId"
        value = module.cbr_zone_schematics.zone_id
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

# Create CBR prewired rules for VPC -> COS (scoped to resource group)
module "vpc_to_cos_cbr_rule" {
  count            = length(local.cos_resource_group_names)
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.20.0"
  rule_description = "This rule only allows requests coming from landing zone VPCs to Cloud Object Storage (COS) which is scoped to resource group"
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