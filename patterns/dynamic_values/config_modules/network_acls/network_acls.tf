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
        name              = "${network_acl}-acl"
        add_cluster_rules = network == "edge" ? false : var.add_cluster_encryption_key
        rules = concat(
          module.acl_rules.default_vpc_rules,
          network_acl != network ? module.acl_rules[network_acl] : []
        )
      }
    ]
  }
}

##############################################################################
