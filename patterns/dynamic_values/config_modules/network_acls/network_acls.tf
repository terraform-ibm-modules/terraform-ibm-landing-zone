##############################################################################
# Variables
##############################################################################

variable "vpc_list" {
  description = "List of VPCs"
  type        = list(string)
}

variable "use_teleport" {
  description = "Use teleport"
  type        = bool
}

variable "use_f5" {
  description = "Use F5"
  type        = bool
}

variable "bastion_vpc_name" {
  description = "Name of VPC where Bastion VSI will be provisioned"
  type        = string
}

variable "add_cluster_encryption_key" {
  description = "Add encryption key for ROKS cluster."
  type        = bool
}

variable "add_ibm_cloud_internal_rules" {
  description = "Add default network ACL rules to VPC"
  type        = bool
}

variable "add_vpc_connectivity_rules" {
  description = "Add connectivity rules across any subnet within VPC"
  type        = bool
}

variable "prepend_ibm_rules" {
  description = "Allow to prepend IBM rules of VPC connectivity"
  type        = bool
}

##############################################################################

##############################################################################
# ACL Rules
##############################################################################

module "acl_rules" {
  source = "../acl_rules"
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map of network ACLs by VPC"
  value = {
    for network in var.vpc_list :
    (network) => [
      for network_acl in concat(
        [network],
        var.use_teleport && network == var.bastion_vpc_name ? ["bastion"] : [],
        var.use_f5 && network == var.vpc_list[0] ? ["f5-external"] : []
      ) :
      {
        name                         = "${network_acl}-acl"
        add_ibm_cloud_internal_rules = network == "edge" ? false : var.add_ibm_cloud_internal_rules
        add_vpc_connectivity_rules   = network == "edge" ? false : var.add_vpc_connectivity_rules
        prepend_ibm_rules            = network == "edge" ? false : var.prepend_ibm_rules
        # Not concatenating default vpc rules (acl_rules) as it will be added from the SLZ-VPC module, preventing the duplication of ACLs
        rules = network_acl != network ? module.acl_rules[network_acl] : []
      }
    ]
  }
}

##############################################################################
