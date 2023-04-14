##############################################################################
# Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "clusters" {
  description = "List of clusters"
}

variable "vpc_modules" {
  description = "VPC modules"
}

##############################################################################

##############################################################################
# Create list of pools with composed name and vpc name to use get_subnets
# to get worker pool subnets
##############################################################################

locals {
  worker_pools_only = flatten(
    [
      for cluster in var.clusters :
      [
        for pool in cluster.worker_pools :
        merge(pool, {
          composed_name = "${var.prefix}-${cluster.name}-${pool.name}",
          vpc_name      = cluster.vpc_name
        }) if pool != null
      ] if cluster.worker_pools != null
    ]
  )
}
##############################################################################

##############################################################################
# Map of worker pools to use for subnet data
##############################################################################

module "worker_pool_subnet_creation_map" {
  source         = "../list_to_map"
  list           = local.worker_pools_only
  key_name_field = "composed_name"
}

##############################################################################

##############################################################################
# Worker pool subnet list by pool
##############################################################################

module "worker_pool_subnets" {
  source           = "../get_subnets"
  for_each         = module.worker_pool_subnet_creation_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = join("|", each.value.subnet_names)
}

##############################################################################

##############################################################################
# Create a list for worker pools
##############################################################################

locals {
  worker_pool_list = flatten(
    [
      for cluster in var.clusters :
      [
        for pool in cluster.worker_pools :
        merge(pool, {
          composed_name  = "${var.prefix}-${cluster.name}-${pool.name}"            # Composed name
          cluster_name   = "${var.prefix}-${cluster.name}"                         # Cluster name with prefix
          entitlement    = cluster.kube_type == "iks" ? null : cluster.entitlement # Add entitlement for roks pools
          resource_group = cluster.resource_group                                  # add cluster rg
          vpc_id         = var.vpc_modules[pool.vpc_name].vpc_id                   # add vpc_id
          subnets        = module.worker_pool_subnets["${var.prefix}-${cluster.name}-${pool.name}"].subnets
          kube_type      = cluster.kube_type
        }) if pool != null
      ] if cluster.worker_pools != null
    ]
  )
}

##############################################################################

##############################################################################
# Worker Pools Map
##############################################################################

module "worker_pool_map" {
  source         = "../list_to_map"
  list           = local.worker_pool_list
  key_name_field = "composed_name"
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "map" {
  description = "Worker pool map"
  value       = module.worker_pool_map.value
}

##############################################################################
