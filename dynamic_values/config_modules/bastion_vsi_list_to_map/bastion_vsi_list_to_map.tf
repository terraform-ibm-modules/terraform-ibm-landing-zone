##############################################################################
# Variables
##############################################################################

variable "vsi_list" {
  description = "List of VSI"
}

variable "prefix" {
  description = "Prefix"
  type        = string
}

variable "vpc_modules" {
  description = "Map of VPC modules"
}

##############################################################################

##############################################################################
# List to map for subnet creation
##############################################################################

module "vsi_list_to_map" {
  source = "../list_to_map"
  list   = var.vsi_list
}

##############################################################################

##############################################################################
# Get subnets for each VSI
##############################################################################

module "vsi_subnets" {
  source           = "../get_subnets"
  for_each         = module.vsi_list_to_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = each.value.subnet_name
}

##############################################################################

##############################################################################
# Composed Bastion VSI list
##############################################################################

module "composed_bastion_vsi_map" {
  source = "../list_to_map"
  prefix = var.prefix
  list = [
    for vsi_group in var.vsi_list :
    merge(vsi_group, {
      # Add VPC ID and subnets
      vpc_id  = var.vpc_modules[vsi_group.vpc_name].vpc_id
      subnets = module.vsi_subnets[vsi_group.name].subnets
    })
  ]
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map of VSI"
  value       = module.composed_bastion_vsi_map.value
}

##############################################################################
