##############################################################################
# Cluster Worker Pools
##############################################################################

module "worker_pools" {
  source      = "./config_modules/cluster_worker_pools"
  prefix      = var.prefix
  clusters    = var.clusters
  vpc_modules = var.vpc_modules
}

##############################################################################

##############################################################################
# [Unit Test] Cluster Worker Pools
##############################################################################

module "ut_worker_pools" {
  source = "./config_modules/cluster_worker_pools"
  prefix = "ut"
  clusters = [
    {
      name           = "test-cluster"
      vpc_name       = "test"
      subnet_names   = ["subnet-1", "subnet-3"]
      resource_group = "test-resource-group"
      kube_type      = "openshift"
      cos_name       = "data-cos"
      entitlement    = "cloud_pak"
      worker_pools = [
        {
          name               = "logging-worker-pool"
          vpc_name           = "test"
          subnet_names       = ["subnet-1", "subnet-3"]
          workers_per_subnet = 2
          flavor             = "spicy"
        }
      ]
    }
  ]
  vpc_modules = {
    test = {
      vpc_id = "1234"
      subnet_zone_list = [
        {
          name = "ut-test-subnet-1"
          id   = "1-id"
          zone = "1-zone"
          cidr = "1"
        },
        { name = "ut-test-subnet-2"
          id   = "2-id"
          zone = "2-zone"
          cidr = "2"
        },
        {
          name = "ut-test-subnet-3"
          id   = "3-id"
          zone = "3-zone"
          cidr = "3"
        },
      ]
    }
  }
}

locals {
  actual_worker_pools_map                      = module.ut_worker_pools.map
  assert_worker_pool_correct_name              = lookup(local.actual_worker_pools_map, "ut-test-cluster-logging-worker-pool")
  assert_worker_pool_correct_vpc_id            = regex("1234", local.actual_worker_pools_map["ut-test-cluster-logging-worker-pool"].vpc_id)
  assert_worker_pool_has_correct_subnet_number = regex("2", tostring(length(local.actual_worker_pools_map["ut-test-cluster-logging-worker-pool"].subnets)))
  assert_worker_pool_map_has_subnets           = regex("ut-test-subnet-1;ut-test-subnet-3", join(";", local.actual_worker_pools_map["ut-test-cluster-logging-worker-pool"].subnets.*.name))
  assert_worker_pool_has_os_parent_entitlement = regex("cloud_pak", local.actual_worker_pools_map["ut-test-cluster-logging-worker-pool"].entitlement)
}

##############################################################################

##############################################################################
# [Unit Test] Worker Pools With Cluster No Pools
##############################################################################

module "ut_cluster_no_worker_pools" {
  source = "./config_modules/cluster_worker_pools"
  prefix = "ut"
  clusters = [
    {
      name           = "test-cluster"
      vpc_name       = "test"
      subnet_names   = ["subnet-1", "subnet-3"]
      resource_group = "test-resource-group"
      kube_type      = "openshift"
      cos_name       = "data-cos"
      entitlement    = "cloud_pak"
      worker_pools   = null
    }
  ]
  vpc_modules = {}
}

locals {
  assert_no_keys = regex("0", tostring(length(keys(module.ut_cluster_no_worker_pools.map))))
}

##############################################################################
