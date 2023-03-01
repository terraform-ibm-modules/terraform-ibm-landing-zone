##############################################################################
# Cluster Locals
##############################################################################

locals {
  workload_cluster = length(module.dynamic_values.clusters_map) >= 1 ? module.dynamic_values.clusters_map["${var.prefix}-workload-cluster"] : null
}

##############################################################################
# Create IKS/ROKS on VPC Cluster
##############################################################################


module "workload_cluster" {
  depends_on = [
    module.vpc, module.observability_instances
  ]
  count             = length(module.dynamic_values.clusters_map) >= 1 ? 1 : 0
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-ocp-all-inclusive.git?ref=v1.0.0"
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = local.resource_groups[local.workload_cluster.resource_group]
  region            = var.region
  cluster_name      = local.workload_cluster.cluster_name
  vpc_id            = local.workload_cluster.vpc_id
  vpc_subnets = {
    vsi-zone-1 = [
      for zone in local.workload_cluster.subnets :
      {
        id         = zone.id
        zone       = zone.zone
        cidr_block = zone.cidr
      }
    ]
  }
  worker_pools                       = var.worker_pools
  ocp_version                        = var.ocp_version
  cluster_tags                       = var.resource_tags
  use_existing_cos                   = true
  disable_public_endpoint            = local.workload_cluster.disable_public_endpoint
  existing_cos_id                    = local.workload_cluster.cos_instance_crn
  existing_key_protect_root_key_id   = module.key_management.key_map[local.workload_cluster.kms_config.crk_name].key_id
  existing_key_protect_instance_guid = module.key_management.key_management_guid
  logdna_instance_name               = module.observability_instances[local.workload_cluster.cluster_name].logdna_name
  logdna_ingestion_key               = module.observability_instances[local.workload_cluster.cluster_name].logdna_ingestion_key
  sysdig_instance_name               = module.observability_instances[local.workload_cluster.cluster_name].sysdig_name
  sysdig_access_key                  = module.observability_instances[local.workload_cluster.cluster_name].sysdig_access_key
  providers = {
    helm = helm.workload_cluster
  }
}

locals {
  management_cluster = length(module.dynamic_values.clusters_map) == 2 ? module.dynamic_values.clusters_map["${var.prefix}-management-cluster"] : null
}

module "management_cluster" {
  depends_on = [
    module.vpc, module.observability_instances
  ]
  count             = length(module.dynamic_values.clusters_map) == 2 ? 1 : 0
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-ocp-all-inclusive.git?ref=v1.0.0"
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = local.resource_groups[local.management_cluster.resource_group]
  region            = var.region
  cluster_name      = local.management_cluster.cluster_name
  vpc_id            = local.management_cluster.vpc_id
  vpc_subnets = {
    vsi-zone-1 = [
      for zone in local.management_cluster.subnets :
      {
        id         = zone.id
        zone       = zone.zone
        cidr_block = zone.cidr
      }
    ]
  }
  worker_pools                       = var.worker_pools
  ocp_version                        = var.ocp_version
  cluster_tags                       = var.resource_tags
  use_existing_cos                   = true
  disable_public_endpoint            = local.management_cluster.disable_public_endpoint
  existing_cos_id                    = local.management_cluster.cos_instance_crn
  existing_key_protect_root_key_id   = module.key_management.key_map[local.management_cluster.kms_config.crk_name].key_id
  existing_key_protect_instance_guid = module.key_management.key_management_guid
  logdna_instance_name               = module.observability_instances[local.management_cluster.cluster_name].logdna_name
  logdna_ingestion_key               = module.observability_instances[local.management_cluster.cluster_name].logdna_ingestion_key
  sysdig_instance_name               = module.observability_instances[local.management_cluster.cluster_name].sysdig_name
  sysdig_access_key                  = module.observability_instances[local.management_cluster.cluster_name].sysdig_access_key
  providers = {
    helm = helm.management_cluster
  }
}
