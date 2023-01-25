provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# Init cluster config for helm and kubernetes providers
# ---------------------------------------------------------------------------------------------------------------------

data "ibm_container_cluster_config" "workload_cluster" {
  count           = length(module.dynamic_values.clusters_map) >= 1 ? 1 : 0
  cluster_name_id = length(module.dynamic_values.clusters_map) >= 1 ? module.workload_cluster[0].cluster_id : ""
}

data "ibm_container_cluster_config" "management_cluster" {
  count           = length(module.dynamic_values.clusters_map) == 2 ? 1 : 0
  cluster_name_id = length(module.dynamic_values.clusters_map) == 2 ? module.management_cluster[0].cluster_id : ""
}

# Helm provider used to deploy cluster-proxy and observability agents
provider "helm" {
  alias = "workload_cluster"
  kubernetes {
    host                   = length(module.dynamic_values.clusters_map) >= 1 ? data.ibm_container_cluster_config.workload_cluster[0].host : ""
    token                  = length(module.dynamic_values.clusters_map) >= 1 ? data.ibm_container_cluster_config.workload_cluster[0].token : ""
    cluster_ca_certificate = length(module.dynamic_values.clusters_map) >= 1 ? data.ibm_container_cluster_config.workload_cluster[0].ca_certificate : ""
  }
}

provider "helm" {
  alias = "management_cluster"
  kubernetes {
    host                   = length(module.dynamic_values.clusters_map) == 2 ? data.ibm_container_cluster_config.management_cluster[0].host : ""
    token                  = length(module.dynamic_values.clusters_map) == 2 ? data.ibm_container_cluster_config.management_cluster[0].token : ""
    cluster_ca_certificate = length(module.dynamic_values.clusters_map) == 2 ? data.ibm_container_cluster_config.management_cluster[0].ca_certificate : ""
  }
}

provider "kubernetes" {
  alias                  = "workload_cluster"
  host                   = data.ibm_container_cluster_config.workload_cluster[0].host
  token                  = data.ibm_container_cluster_config.workload_cluster[0].token
  cluster_ca_certificate = data.ibm_container_cluster_config.workload_cluster[0].ca_certificate
}

provider "kubernetes" {
  alias                  = "management_cluster"
  host                   = data.ibm_container_cluster_config.management_cluster[0].host
  token                  = data.ibm_container_cluster_config.management_cluster[0].token
  cluster_ca_certificate = data.ibm_container_cluster_config.management_cluster[0].ca_certificate
}
