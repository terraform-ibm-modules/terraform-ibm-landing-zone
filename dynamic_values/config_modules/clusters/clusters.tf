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

variable "cos_instance_ids" {
  description = "COS instance IDs"
}

##############################################################################

##############################################################################
# Convert clusters to map to get subnets
##############################################################################

module "cluster_map" {
  source = "../list_to_map"
  list   = var.clusters
}

##############################################################################

##############################################################################
# Cluster subnets
##############################################################################

module "cluster_subnets" {
  source           = "../get_subnets"
  for_each         = module.cluster_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = join("|", each.value.subnet_names)
}

##############################################################################

module "worker_pools" {
  source      = "../cluster_worker_pools"
  prefix      = var.prefix
  clusters    = var.clusters
  vpc_modules = var.vpc_modules
}

##############################################################################
# Cluster List To Map
##############################################################################

module "composed_cluster_map" {
  source = "../list_to_map"
  list = [
    for cluster in var.clusters :
    merge(cluster, {
      vpc_id           = var.vpc_modules[cluster.vpc_name].vpc_id
      subnets          = module.cluster_subnets[cluster.name].subnets
      cos_instance_crn = cluster.kube_type == "openshift" ? var.cos_instance_ids[cluster.cos_name] : null
      cluster_name     = "${var.prefix}-${cluster.name}"
      vpc_subnets = {
        (cluster.subnet_names[0]) = [
          for zone in module.cluster_subnets[cluster.name].subnets :
          {
            id         = zone.id
            zone       = zone.zone
            cidr_block = zone.cidr
          }
        ]

      }
      worker = cluster.worker_pools != null ? [
        for pool in cluster.worker_pools :
        merge(module.worker_pools.map["${var.prefix}-${cluster.name}-${pool.name}"], {
          vpc_subnets = [
            for zone in module.worker_pools.map["${var.prefix}-${cluster.name}-${pool.name}"].subnets :
            {
              id         = zone.id
              zone       = zone.zone
              cidr_block = zone.cidr
            }
          ]
        }) if pool != null
      ] : []
    })
  ]
  prefix = var.prefix
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "map" {
  description = "Map of clusters by name"
  value       = module.composed_cluster_map.value
}

##############################################################################
