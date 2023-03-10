##############################################################################
# Cluster Locals
##############################################################################

locals {
  cluster_1 = length(module.dynamic_values.clusters_map) == 1 ? module.dynamic_values.clusters_list[0] : null
  cluster_2 = length(module.dynamic_values.clusters_map) == 2 ? module.dynamic_values.clusters_list[1] : null
}

##############################################################################
# Create ROKS on VPC Cluster
##############################################################################


module "cluster_1" {
  depends_on = [
    module.vpc, module.observability_instances
  ]
  count             = local.cluster_1 != null ? 1 : 0
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-ocp-all-inclusive.git?ref=v1.0.0"
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = local.resource_groups[local.cluster_1.resource_group]
  region            = var.region
  cluster_name      = local.cluster_1.cluster_name
  vpc_id            = local.cluster_1.vpc_id
  vpc_subnets = {
    vsi-zone-1 = [
      for zone in local.cluster_1.subnets :
      {
        id         = zone.id
        zone       = zone.zone
        cidr_block = zone.cidr
      }
    ]
  }
  worker_pools                       = var.worker_pools
  ocp_version                        = local.cluster_1.ocp_version
  cluster_tags                       = var.resource_tags
  use_existing_cos                   = true
  disable_public_endpoint            = local.cluster_1.disable_public_endpoint
  existing_cos_id                    = local.cluster_1.cos_instance_crn
  existing_key_protect_root_key_id   = module.key_management.key_map[local.cluster_1.kms_config.crk_name].key_id
  existing_key_protect_instance_guid = module.key_management.key_management_guid
  logdna_instance_name               = module.observability_instances[local.cluster_1.cluster_name].logdna_name
  logdna_ingestion_key               = module.observability_instances[local.cluster_1.cluster_name].logdna_ingestion_key
  sysdig_instance_name               = module.observability_instances[local.cluster_1.cluster_name].sysdig_name
  sysdig_access_key                  = module.observability_instances[local.cluster_1.cluster_name].sysdig_access_key
  providers = {
    helm = helm.cluster_1
  }
}

module "cluster_2" {
  depends_on = [
    module.vpc, module.observability_instances
  ]
  count             = local.cluster_2 != null ? 1 : 0
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-ocp-all-inclusive.git?ref=v1.0.0"
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = local.resource_groups[local.cluster_2.resource_group]
  region            = var.region
  cluster_name      = local.cluster_2.cluster_name
  vpc_id            = local.cluster_2.vpc_id
  vpc_subnets = {
    vsi-zone-1 = [
      for zone in local.cluster_2.subnets :
      {
        id         = zone.id
        zone       = zone.zone
        cidr_block = zone.cidr
      }
    ]
  }
  worker_pools                       = var.worker_pools
  ocp_version                        = local.cluster_2.ocp_version
  cluster_tags                       = var.resource_tags
  use_existing_cos                   = true
  disable_public_endpoint            = local.cluster_2.disable_public_endpoint
  existing_cos_id                    = local.cluster_2.cos_instance_crn
  existing_key_protect_root_key_id   = module.key_management.key_map[local.cluster_2.kms_config.crk_name].key_id
  existing_key_protect_instance_guid = module.key_management.key_management_guid
  logdna_instance_name               = module.observability_instances[local.cluster_2.cluster_name].logdna_name
  logdna_ingestion_key               = module.observability_instances[local.cluster_2.cluster_name].logdna_ingestion_key
  sysdig_instance_name               = module.observability_instances[local.cluster_2.cluster_name].sysdig_name
  sysdig_access_key                  = module.observability_instances[local.cluster_2.cluster_name].sysdig_access_key
  providers = {
    helm = helm.cluster_2
  }
}
