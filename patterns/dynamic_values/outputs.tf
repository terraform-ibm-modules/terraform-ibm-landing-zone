##############################################################################
# Outputs
##############################################################################

output "default_vsi_sg_rules" {
  description = "Default rules added to VSI security groups"
  value       = local.default_vsi_sg_rules
}

##############################################################################

##############################################################################
# Bastion / Teleport Outputs
##############################################################################

output "teleport_vsi" {
  description = "List of teleport VSI to create using landing zone module"
  value       = local.teleport_vsi
}

##############################################################################

##############################################################################
# Object Storage Outputs
##############################################################################

output "object_storage" {
  description = "List of object storage instances and buckets"
  value       = local.object_storage
}

##############################################################################


##############################################################################
# F5 Outputs
##############################################################################

output "f5_deployments" {
  description = "List of F5 deployments for landing-zone module"
  value       = local.f5_deployments
}

##############################################################################

##############################################################################
# Key Management Outputs
##############################################################################

output "key_management" {
  description = "Key management map for landing zone"
  value       = local.key_management
}

##############################################################################

##############################################################################
# Resource Group Outputs
##############################################################################

output "resource_groups" {
  description = "List of resource groups transformed to use as landing zone configuration"
  value       = local.resource_groups
}

##############################################################################


##############################################################################
# VPC Value Outputs
##############################################################################

output "vpc_list" {
  description = "List of VPCs, used for adding Edge VPC"
  value       = local.vpc_list
}

output "vpcs" {
  description = "List of VPCs with needed information to be created by landing zone module"
  value       = local.vpcs
}

output "security_groups" {
  description = "List of additional security groups to be created by landing-zone module"
  value       = local.security_groups
}

##############################################################################

##############################################################################
# VPN Gateway Outputs
##############################################################################

output "vpn_gateways" {
  description = "List of gateways for landing zone module"
  value       = local.vpn_gateways
}

##############################################################################
