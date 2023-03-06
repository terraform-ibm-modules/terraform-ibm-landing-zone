provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# Init cluster config for helm and kubernetes providers
# ---------------------------------------------------------------------------------------------------------------------

data "ibm_container_cluster_config" "workload_cluster" {
  count           = lookup(module.dynamic_values.clusters_map, "${var.prefix}-workload-cluster", false) != false ? 1 : 0
  cluster_name_id = lookup(module.dynamic_values.clusters_map, "${var.prefix}-workload-cluster", false) != false ? module.workload_cluster[0].cluster_id : ""
}

data "ibm_container_cluster_config" "management_cluster" {
  count           = lookup(module.dynamic_values.clusters_map, "${var.prefix}-management-cluster", false) != false ? 1 : 0
  cluster_name_id = lookup(module.dynamic_values.clusters_map, "${var.prefix}-management-cluster", false) != false ? module.management_cluster[0].cluster_id : ""
}

provider "helm" {
  alias = "workload_cluster"
  kubernetes {
    host                   = lookup(module.dynamic_values.clusters_map, "${var.prefix}-workload-cluster", false) != false ? data.ibm_container_cluster_config.workload_cluster[0].host : ""
    token                  = lookup(module.dynamic_values.clusters_map, "${var.prefix}-workload-cluster", false) != false ? data.ibm_container_cluster_config.workload_cluster[0].token : ""
    cluster_ca_certificate = lookup(module.dynamic_values.clusters_map, "${var.prefix}-workload-cluster", false) != false ? data.ibm_container_cluster_config.workload_cluster[0].ca_certificate : ""
  }
}

provider "helm" {
  alias = "management_cluster"
  kubernetes {
    host                   = lookup(module.dynamic_values.clusters_map, "${var.prefix}-management-cluster", false) != false ? data.ibm_container_cluster_config.management_cluster[0].host : ""
    token                  = lookup(module.dynamic_values.clusters_map, "${var.prefix}-management-cluster", false) != false ? data.ibm_container_cluster_config.management_cluster[0].token : ""
    cluster_ca_certificate = lookup(module.dynamic_values.clusters_map, "${var.prefix}-management-cluster", false) != false ? data.ibm_container_cluster_config.management_cluster[0].ca_certificate : ""
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
