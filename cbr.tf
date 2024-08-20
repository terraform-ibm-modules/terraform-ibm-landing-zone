##############################################################################
# Create CBR zone for all VPCs
##############################################################################

# Allow schematics, from outside VPC, to manage resources
module "cbr_zone_schematics" {
  count            = var.exisiting_schematics_cbr_zone_id == null ? 1 : 0
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
  count            = var.exisiting_VPC_cbr_zone_id == null ? 1 : 0
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

#   output "cos_bucket_data" {
#   description = "List of data for COS buckets creaed"
  # value = [
  #   for instance in ibm_cos_bucket.buckets :
  #   instance
  # ]
# }

  cos_data_merge_maps = merge(local.cos_data_map, local.cos_map)

  cos_resource_group_names = distinct(flatten([
    for key, value in local.cos_data_merge_maps : [
      value
    ]
  ]))

  cos_bucket_crns = [
    for instance in ibm_cos_bucket.buckets :
    instance.crn
  ]

  cbr_vpc_zone_id = var.exisiting_VPC_cbr_zone_id != null ? var.exisiting_VPC_cbr_zone_id : module.cbr_zone_vpcs[0].zone_id
  cbr_schematics_zone_id = var.exisiting_schematics_cbr_zone_id != null ? var.exisiting_schematics_cbr_zone_id : module.cbr_zone_schematics[0].zone_id
  network_zone_ids_list = concat(cbr_vpc_zone_id, cbr_schematics_zone_id)

  rule_contexts = [{
    attributes = [
      {
        "name" : "endpointType",
        "value" : "private"
      },
      {
        name  = "networkZoneId"
        value = join(",", local.network_zone_ids_list)
    }]
    }]

  target_service_details = concat(
    [
      for cos_bucket_crn in local.cos_bucket_crns : {
        target_service_name = "cloud-object-storage",
        instance_id         = cos_bucket_crn
        tags                = var.tags
      }
    ],
    [
      {
        target_service_name = "container-registry",
      }
    ]
  )

  #   target_service_details = {
  #   # Using 'kms' for Key Protect value as target service name supported by CBR for Key Protect is 'kms'.
  #    for cos_bucket_crn in local.cos_bucket_crns : "cloud-object-storage" =>  {
  #     "description"      = "This rule only allows requests coming from landing zone VPCs to Cloud Object Storage (COS) which is scoped to resource group"
  #     "enforcement_mode" = "enabled"
  #     "instance_id"      = cos_bucket_crn
  #   }
  #   # "container-registry" = {
  #   #   "description"      = "This rule only allows requests coming from landing zone VPCs to Container Registery"
  #   # }
  # }

  
}

output "cos_resource_group_names" {
  value = local.target_service_details
}

# Create CBR prewired rules for VPC -> COS (scoped to resource group)
# module "vpc_to_cos_cbr_rule" {
#   count            = length(local.cos_resource_group_names)
#   source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
#   version          = "1.20.0"
#   rule_description = "This rule only allows requests coming from landing zone VPCs to Cloud Object Storage (COS) which is scoped to resource group"
#   enforcement_mode = var.enforcement_mode
#   rule_contexts    = local.rule_contexts
#   operations = [{
#     api_types = [{
#       api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
#     }]
#   }]

#   resources = [{
#     tags = local.target_service_details[count.index].tags != null ? [for tag in local.target_service_details[count.index].tags : {
#       name  = split(":", tag)[0]
#       value = split(":", tag)[1]
#     }] : []
#     attributes = local.target_service_details[count.index].target_rg != null ? [
#       {
#         name     = "accountId",
#         operator = "stringEquals",
#         value    = data.ibm_iam_account_settings.iam_account_settings.account_id
#       },
#       {
#         name     = "resourceGroupId",
#         operator = "stringEquals",
#         value    = local.target_service_details[count.index].target_rg
#       },
#       {
#         name     = "serviceName",
#         operator = "stringEquals",
#         value    = local.target_service_details[count.index].target_service_name
#       }] : [
#       {
#         name     = "accountId",
#         operator = "stringEquals",
#         value    = data.ibm_iam_account_settings.iam_account_settings.account_id
#       },
#       {
#         name     = "serviceName",
#         operator = "stringEquals",
#         value    = local.target_service_details[count.index].target_service_name
#     }]
#   }]
# }

##############################################################################
