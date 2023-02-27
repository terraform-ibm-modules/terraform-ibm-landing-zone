##############################################################################
# Clusters
##############################################################################

module "clusters" {
  source           = "./config_modules/clusters"
  prefix           = var.prefix
  clusters         = var.clusters
  vpc_modules      = var.vpc_modules
  cos_instance_ids = local.cos_instance_ids
}

##############################################################################

##############################################################################
# [Unit Test] Cluster Map
##############################################################################

module "ut_cluster_map" {
  source = "./config_modules/clusters"
  prefix = "ut"
  clusters = [
    {
      name                    = "test-cluster"
      vpc_name                = "test"
      subnet_names            = ["subnet-1", "subnet-3"]
      resource_group          = "test-resource-group"
      kube_type               = "openshift"
      cos_name                = "data-cos"
      logdna_plan             = "7-day"
      sysdig_plan             = "graduated-tier"
      disable_public_endpoint = false
      enable_platform_logs    = false
      enable_platform_metrics = false
      entitlement             = "cloud_pak"
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
  cos_instance_ids = {
    data-cos = "cosid"
  }
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
  actual_clusters_map                      = module.ut_cluster_map.map
  assert_cluster_map_correct_name          = lookup(local.actual_clusters_map, "ut-test-cluster")
  assert_cluster_map_correct_vpc_id        = regex("1234", local.actual_clusters_map["ut-test-cluster"].vpc_id)
  assert_cluster_map_correct_cos_crn       = regex("cosid", local.actual_clusters_map["ut-test-cluster"].cos_instance_crn)
  assert_cluster_map_correct_subnet_number = regex("2", tostring(length(local.actual_clusters_map["ut-test-cluster"].subnets)))
  assert_cluster_map_has_subnets           = regex("ut-test-subnet-1;ut-test-subnet-3", join(";", local.actual_clusters_map["ut-test-cluster"].subnets.*.name))
}

##############################################################################
