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
  depends_on        = [ibm_iam_authorization_policy.policy]
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
  # if kube_version is older than 4.15, default this value to null, otherwise provider will fail
  disable_outbound_traffic_protection = startswith((lookup(each.value, "kube_version", null) == "default" || lookup(each.value, "kube_version", null) == null ? local.default_kube_version[each.value.kube_type] : each.value.kube_version), "4.12") || startswith((lookup(each.value, "kube_version", null) == "default" || lookup(each.value, "kube_version", null) == null ? local.default_kube_version[each.value.kube_type] : each.value.kube_version), "4.13") || startswith((lookup(each.value, "kube_version", null) == "default" || lookup(each.value, "kube_version", null) == null ? local.default_kube_version[each.value.kube_type] : each.value.kube_version), "4.14") ? null : each.value.disable_outbound_traffic_protection
  force_delete_storage                = each.value.cluster_force_delete_storage
  crk                                 = each.value.boot_volume_crk_name == null ? null : regex("key:(.*)", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
  kms_instance_id                     = each.value.boot_volume_crk_name == null ? null : regex(".*:(.*):key:.*", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
  kms_account_id                      = each.value.boot_volume_crk_name == null ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0] == data.ibm_iam_account_settings.iam_account_settings.account_id ? null : regex("a/([a-f0-9]{32})", module.key_management.key_map[each.value.boot_volume_crk_name].crn)[0]
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
      wait_for_apply   = each.value.kms_wait_for_apply
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

##############################################################################
# Addons
##############################################################################

# Lookup the current default csi-driver version
data "ibm_container_addons" "existing_addons" {
  for_each = ibm_container_vpc_cluster.cluster
  cluster  = each.value.id
}

locals {
  # for each cluster, look for installed csi driver to get version. If array is empty (no csi driver) then null is returned
  csi_driver_version = {
    for cluster in ibm_container_vpc_cluster.cluster : cluster.name => (
      one([
        for addon in data.ibm_container_addons.existing_addons[cluster.name].addons :
        addon.version if addon.name == "vpc-block-csi-driver"
      ])
    )
  }

  # for each cluster in the clusters_map, get the addons and their versions and create an addons map including the corosponding csi_driver_version
  cluster_addons = {
    for cluster in var.clusters : "${var.prefix}-${cluster.name}" => {
      id                = ibm_container_vpc_cluster.cluster["${var.prefix}-${cluster.name}"].id
      resource_group_id = ibm_container_vpc_cluster.cluster["${var.prefix}-${cluster.name}"].resource_group_id
      addons = merge(
        { for addon_name, addon_version in(cluster.addons != null ? cluster.addons : {}) : addon_name => addon_version if addon_version != null },
        local.csi_driver_version["${var.prefix}-${cluster.name}"] != null ? { vpc-block-csi-driver = local.csi_driver_version["${var.prefix}-${cluster.name}"] } : {}
      )
    }
  }
}

resource "ibm_container_addons" "addons" {
  # Worker pool creation can start before the 'ibm_container_vpc_cluster' completes since there is no explicit
  # depends_on in 'ibm_container_vpc_worker_pool', just an implicit depends_on on the cluster ID. Cluster ID can exist before
  # 'ibm_container_vpc_cluster' completes, so hence need to add explicit depends on against 'ibm_container_vpc_cluster' here.
  depends_on = [ibm_container_vpc_cluster.cluster, ibm_container_vpc_worker_pool.pool]
  # only apply this addons block if the cluster has addons to manage (the addons parameter has entries)
  for_each          = local.cluster_addons
  cluster           = each.value.id
  resource_group_id = each.value.resource_group_id

  # setting to false means we do not want Terraform to manage addons that are managed elsewhere
  manage_all_addons = local.clusters_map[each.key].manage_all_addons

  dynamic "addons" {
    for_each = each.value.addons
    content {
      name    = addons.key
      version = addons.value
    }
  }

  timeouts {
    create = "1h"
  }
}
