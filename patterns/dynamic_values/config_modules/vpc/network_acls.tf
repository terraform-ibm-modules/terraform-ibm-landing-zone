##############################################################################
# [Unit Test] Network ACLs
##############################################################################

module "default_network_acls" {
  source                       = "../network_acls"
  vpc_list                     = ["management", "workload"]
  use_teleport                 = false
  use_f5                       = false
  bastion_vpc_name             = false
  add_cluster_encryption_key   = false
  add_ibm_cloud_internal_rules = false
  add_vpc_connectivity_rules   = false
  prepend_ibm_rules            = false
}

locals {
  default_network_acls_each_has_one = regex("true", tostring(
    length(
      distinct(
        flatten(
          [
            for network in module.default_network_acls.value :
            length(network) == 1
          ]
        )
      )
    ) == 1
  ))
}

##############################################################################

##############################################################################
# [Unit Test] F5 and Bastion Network ACLs
##############################################################################

module "f5_and_bastion_network_acls" {
  source                       = "../network_acls"
  vpc_list                     = ["management", "workload"]
  use_teleport                 = true
  use_f5                       = true
  bastion_vpc_name             = "management"
  add_cluster_encryption_key   = false
  add_ibm_cloud_internal_rules = false
  add_vpc_connectivity_rules   = false
  prepend_ibm_rules            = false
}

locals {
  f5_and_bastion_network_acls_has_3_acls_management = regex("3", length(module.f5_and_bastion_network_acls.value["management"]))
}

##############################################################################
