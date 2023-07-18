##############################################################################
# Find valid IKS/ROKS Cluster versions for region
##############################################################################

data "ibm_container_cluster_versions" "cluster_versions" {}

##############################################################################


##############################################################################
# Cluster Locals
##############################################################################

locals {
  worker_pools_map = module.dynamic_values.worker_pools_map # Convert list to map
  clusters_map     = module.dynamic_values.clusters_map     # Convert list to map
  latest_kube_version = {
    openshift = "${data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions[length(data.ibm_container_cluster_versions.cluster_versions.valid_openshift_versions) - 1]}_openshift"
    iks       = data.ibm_container_cluster_versions.cluster_versions.valid_kube_versions[length(data.ibm_container_cluster_versions.cluster_versions.valid_kube_versions) - 1]
  }
}

##############################################################################


##############################################################################
# Create IKS/ROKS on VPC Cluster
##############################################################################

resource "ibm_container_vpc_cluster" "cluster" {
  for_each          = local.clusters_map
  name              = "${var.prefix}-${each.value.name}"
  vpc_id            = each.value.vpc_id
  resource_group_id = local.resource_groups[each.value.resource_group]
  flavor            = each.value.machine_type
  worker_count      = each.value.workers_per_subnet
  kube_version = (
    lookup(each.value, "kube_version", null) == "latest" # if version is latest
    || lookup(each.value, "kube_version", null) == null  # or if version is null
    ? local.latest_kube_version[each.value.kube_type]    # use latest
    : each.value.kube_version                            # otherwise use value
  )
  update_all_workers = lookup(each.value, "update_all_workers", null)
  tags               = var.tags
  wait_till          = var.wait_till
  entitlement        = each.value.entitlement
  cos_instance_crn   = each.value.cos_instance_crn
  pod_subnet         = each.value.pod_subnet
  service_subnet     = each.value.service_subnet

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
  for_each    = local.clusters_map
  resource_id = ibm_container_vpc_cluster.cluster[each.key].crn
  tag_type    = "access"
  tags        = each.value.access_tags
}

##############################################################################


##############################################################################
# Create Worker Pools
##############################################################################

resource "ibm_container_vpc_worker_pool" "pool" {
  for_each          = local.worker_pools_map
  vpc_id            = each.value.vpc_id
  resource_group_id = local.resource_groups[each.value.resource_group]
  entitlement       = each.value.entitlement
  cluster           = ibm_container_vpc_cluster.cluster[each.value.cluster_name].id
  worker_pool_name  = each.value.name
  flavor            = each.value.flavor
  worker_count      = each.value.workers_per_subnet

  dynamic "zones" {
    for_each = each.value.subnets
    content {
      subnet_id = zones.value["id"]
      name      = zones.value["zone"]
    }
  }
}

##############################################################################
