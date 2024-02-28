##############################################################################
# Find valid IKS/ROKS Cluster versions for region
##############################################################################

data "ibm_container_cluster_versions" "cluster_versions" {}

##############################################################################

##############################################################################
# Get account id
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {}

##############################################################################


##############################################################################
# Cluster Locals
##############################################################################

locals {
  worker_pools_map = module.dynamic_values.worker_pools_map # Convert list to map
  clusters_map     = module.dynamic_values.clusters_map     # Convert list to map
  default_kube_version = {
    openshift = "${data.ibm_container_cluster_versions.cluster_versions.default_openshift_version}_openshift"
    iks       = data.ibm_container_cluster_versions.cluster_versions.default_kube_version
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
  # if version is default or null then use default
  # otherwise use value
  kube_version = (
    lookup(each.value, "kube_version", null) == "default" || lookup(each.value, "kube_version", null) == null
    ? local.default_kube_version[each.value.kube_type] : each.value.kube_version
  )
  tags              = var.tags
  wait_till         = var.wait_till
  entitlement       = each.value.entitlement
  secondary_storage = each.value.secondary_storage
  cos_instance_crn  = each.value.cos_instance_crn
  pod_subnet        = each.value.pod_subnet
  service_subnet    = each.value.service_subnet
  crk               = each.value.boot_volume_crk_name == null ? null : regex("key:(.*)", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
  kms_instance_id   = each.value.boot_volume_crk_name == null ? null : regex(".*:(.*):key:.*", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
  kms_account_id    = each.value.boot_volume_crk_name == null ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0] == data.ibm_iam_account_settings.iam_account_settings.account_id ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
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
      crk_id           = regex("key:(.*)", module.key_management.key_map[kms_config.value.crk_name].crn)[0]
      instance_id      = regex(".*:(.*):key:.*", module.key_management.key_map[kms_config.value.crk_name].crn)[0]
      private_endpoint = kms_config.value.private_endpoint
      account_id       = regex("a/([a-f0-9]{32})", module.key_management.key_map[kms_config.value.crk_name].crn)[0] == data.ibm_iam_account_settings.iam_account_settings.account_id ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[kms_config.value.crk_name].crn)[0]
    }
  }

  disable_public_service_endpoint = coalesce(each.value.disable_public_endpoint, true) # disable if not set or null

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
  secondary_storage = each.value.secondary_storage
  flavor            = each.value.flavor
  worker_count      = each.value.workers_per_subnet
  crk               = each.value.boot_volume_crk_name == null ? null : regex("key:(.*)", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
  kms_instance_id   = each.value.boot_volume_crk_name == null ? null : regex(".*:(.*):key:.*", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
  kms_account_id    = each.value.boot_volume_crk_name == null ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0] == data.ibm_iam_account_settings.iam_account_settings.account_id ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]

  dynamic "zones" {
    for_each = each.value.subnets
    content {
      subnet_id = zones.value["id"]
      name      = zones.value["zone"]
    }
  }
}

##############################################################################
