provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# Init cluster config for helm and kubernetes providers
# ---------------------------------------------------------------------------------------------------------------------

data "ibm_container_cluster_config" "cluster_1" {
  count           = length(module.dynamic_values.clusters_map) == 1 ? 1 : 0
  cluster_name_id = length(module.dynamic_values.clusters_map) == 1 ? module.cluster_1[0].cluster_id : ""
}

data "ibm_container_cluster_config" "cluster_2" {
  count           = length(module.dynamic_values.clusters_map) == 2 ? 1 : 0
  cluster_name_id = length(module.dynamic_values.clusters_map) == 2 ? module.cluster_2[0].cluster_id : ""
}

provider "helm" {
  alias = "cluster_1"
  kubernetes {
    host                   = length(module.dynamic_values.clusters_map) == 1 ? data.ibm_container_cluster_config.cluster_1[0].host : ""
    token                  = length(module.dynamic_values.clusters_map) == 1 ? data.ibm_container_cluster_config.cluster_1[0].token : ""
    cluster_ca_certificate = length(module.dynamic_values.clusters_map) == 1 ? data.ibm_container_cluster_config.cluster_1[0].ca_certificate : ""
  }
}

provider "helm" {
  alias = "cluster_2"
  kubernetes {
    host                   = length(module.dynamic_values.clusters_map) == 2 ? data.ibm_container_cluster_config.cluster_2[0].host : ""
    token                  = length(module.dynamic_values.clusters_map) == 2 ? data.ibm_container_cluster_config.cluster_2[0].token : ""
    cluster_ca_certificate = length(module.dynamic_values.clusters_map) == 2 ? data.ibm_container_cluster_config.cluster_2[0].ca_certificate : ""
  }
}

provider "kubernetes" {
  alias                  = "cluster_1"
  host                   = data.ibm_container_cluster_config.cluster_1[0].host
  token                  = data.ibm_container_cluster_config.cluster_1[0].token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_1[0].ca_certificate
}

provider "kubernetes" {
  alias                  = "cluster_2"
  host                   = data.ibm_container_cluster_config.cluster_2[0].host
  token                  = data.ibm_container_cluster_config.cluster_2[0].token
  cluster_ca_certificate = data.ibm_container_cluster_config.cluster_2[0].ca_certificate
}
