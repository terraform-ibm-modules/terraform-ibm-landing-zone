##############################################################################
# Find valid IKS/ROKS Cluster versions for region
##############################################################################

data "ibm_container_cluster_versions" "cluster_versions" {}

##############################################################################

##############################################################################
# Cluster Locals
##############################################################################

locals {
  clusters_map     = module.dynamic_values.clusters_map     # Convert list to map
  worker_pools_map = module.dynamic_values.worker_pools_map # Convert list to map

  latest_kube_version = {
    openshift = data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions[length(data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions) - 1]
    iks       = data.ibm_container_cluster_versions.cluster_versions.valid_kube_versions[length(data.ibm_container_cluster_versions.cluster_versions.valid_kube_versions) - 1]
  }
  default_kube_version = {
    openshift = "${data.ibm_container_cluster_versions.cluster_versions.default_openshift_version}_openshift"
    iks       = data.ibm_container_cluster_versions.cluster_versions.default_kube_version
  }

  cluster_data = merge({
    for cluster in ibm_container_vpc_cluster.cluster :
    cluster.name => {
      crn                 = cluster.crn
      id                  = cluster.id
      resource_group_name = cluster.resource_group_name
      resource_group_id   = cluster.resource_group_id
      vpc_id              = cluster.vpc_id
      region              = var.region
    }
    }, {
    for cluster in module.cluster :
    cluster.cluster_name => {
      crn               = cluster.cluster_crn
      id                = cluster.cluster_id
      resource_group_id = cluster.resource_group_id
      vpc_id            = cluster.vpc_id
      region            = var.region
    }
    }
  )
}


##############################################################################
# Create IKS on VPC Cluster
##############################################################################

resource "ibm_container_vpc_cluster" "cluster" {
  for_each = {
    for index, cluster in local.clusters_map : index => cluster
    if cluster.kube_type == "iks"
  }
  name              = "${var.prefix}-${each.value.name}"
  vpc_id            = each.value.vpc_id
  resource_group_id = local.resource_groups[each.value.resource_group]
  flavor            = each.value.machine_type
  worker_count      = each.value.workers_per_subnet
  # if version is default or null then use default
  # if version is latest then use latest
  # otherwise use value
  kube_version = (
    lookup(each.value, "kube_version", null) == "default" || lookup(each.value, "kube_version", null) == null
    ? local.default_kube_version[each.value.kube_type]
    : (lookup(each.value, "kube_version", null) == "latest" ? local.latest_kube_version[each.value.kube_type] : each.value.kube_version)
  )
  update_all_workers = lookup(each.value, "update_all_workers", null)
  tags               = var.tags
  wait_till          = var.wait_till
  entitlement        = each.value.entitlement
  cos_instance_crn   = each.value.cos_instance_crn
  pod_subnet         = each.value.pod_subnet
  service_subnet     = each.value.service_subnet
  crk                = each.value.boot_volume_crk_name == null ? null : module.key_management.key_map[each.value.boot_volume_crk_name].key_id
  kms_instance_id    = each.value.boot_volume_crk_name == null ? null : module.key_management.key_management_guid
  lifecycle {
    ignore_changes = [kube_version]
  }

  dynamic "zones" {
    for_each = each.value.subnets
    content {
      subnet_id = zones.value["id"]
      name      = zones.value["zone"]
    }
  }

  dynamic "kms_config" {
    for_each = each.value.kms_config == null ? [] : [each.value.kms_config]
    content {
      crk_id           = module.key_management.key_map[kms_config.value.crk_name].key_id
      instance_id      = module.key_management.key_management_guid
      private_endpoint = kms_config.value.private_endpoint
    }
  }

  disable_public_service_endpoint = true

  timeouts {
    create = "3h"
    delete = "2h"
    update = "3h"
  }
}

resource "ibm_resource_tag" "cluster_tag" {
  for_each = {
    for index, cluster in local.clusters_map : index => cluster
    if cluster.kube_type == "iks"
  }
  resource_id = ibm_container_vpc_cluster.cluster[each.key].crn
  tag_type    = "access"
  tags        = each.value.access_tags
}

##############################################################################


##############################################################################
# Create IKS Worker Pools
##############################################################################

resource "ibm_container_vpc_worker_pool" "pool" {
  for_each = {
    for index, cluster in local.worker_pools_map : index => cluster
    if cluster.kube_type == "iks"
  }
  vpc_id            = each.value.vpc_id
  resource_group_id = local.resource_groups[each.value.resource_group]
  entitlement       = each.value.entitlement
  cluster           = ibm_container_vpc_cluster.cluster[each.value.cluster_name].id
  worker_pool_name  = each.value.name
  flavor            = each.value.flavor
  worker_count      = each.value.workers_per_subnet
  crk               = each.value.boot_volume_crk_name == null ? null : module.key_management.key_map[each.value.boot_volume_crk_name].key_id
  kms_instance_id   = each.value.boot_volume_crk_name == null ? null : module.key_management.key_management_guid

  dynamic "zones" {
    for_each = each.value.subnets
    content {
      subnet_id = zones.value["id"]
      name      = zones.value["zone"]
    }
  }
}

##############################################################################


##############################################################################
# Create ROKS on VPC Cluster
##############################################################################

module "cluster" {
  for_each = {
    for index, cluster in local.clusters_map : index => cluster
    if cluster.kube_type == "openshift"
  }
  source            = "terraform-ibm-modules/base-ocp-vpc/ibm"
  version           = "3.11.1"
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = local.resource_groups[each.value.resource_group]
  region            = var.region
  cluster_name      = each.value.cluster_name
  vpc_id            = each.value.vpc_id
  ocp_entitlement   = each.value.entitlement
  vpc_subnets       = each.value.vpc_subnets
  access_tags       = each.value.access_tags
  worker_pools = concat(
    [
      {
        subnet_prefix    = each.value.subnet_names[0]
        pool_name        = "default"
        machine_type     = each.value.machine_type
        workers_per_zone = each.value.workers_per_subnet
        boot_volume_encryption_kms_config = {
          crk             = module.key_management.key_map[each.value.kms_config.crk_name].key_id
          kms_instance_id = module.key_management.key_management_guid
        }
      }
    ],
    each.value.worker != null ? [
      for pool in each.value.worker :
      {
        vpc_subnets      = pool.vpc_subnets
        pool_name        = pool.name
        machine_type     = pool.flavor
        workers_per_zone = pool.workers_per_subnet
        boot_volume_encryption_kms_config = {
          crk             = module.key_management.key_map[each.value.kms_config.crk_name].key_id
          kms_instance_id = module.key_management.key_management_guid
        }
      }
    ] : []
  )
  ocp_version                     = each.value.kube_version
  tags                            = var.tags
  use_existing_cos                = true
  disable_public_endpoint         = each.value.disable_public_endpoint != null ? each.value.disable_public_endpoint : true
  verify_worker_network_readiness = each.value.verify_worker_network_readiness != null ? each.value.verify_worker_network_readiness : false
  existing_cos_id                 = each.value.cos_instance_crn
  kms_config = {
    instance_id = module.key_management.key_management_guid
    crk_id      = module.key_management.key_map[each.value.kms_config.crk_name].key_id
  }
}
