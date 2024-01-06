##############################################################################
# Cluster Outputs
##############################################################################

output "clusters_map" {
  description = "Cluster Map for dynamic cluster creation"
  value       = module.clusters.map
}

output "worker_pools_map" {
  description = "Cluster worker pools map"
  value       = module.worker_pools.map
}

##############################################################################

##############################################################################
# COS Outputs
##############################################################################

output "cos_data_map" {
  description = "Map of COS data resources"
  value       = module.cos.cos_data_map
}

output "cos_map" {
  description = "Map of COS resources"
  value       = module.cos.cos_map
}

output "cos_instance_ids" {
  description = "Instance map for cloud object storage instance IDs"
  value       = module.cos.cos_instance_ids
}

output "cos_bucket_map" {
  description = "Map including key of bucket names with bucket data as values"
  value       = module.cos.cos_bucket_map
}

output "cos_key_map" {
  description = "Map of COS keys"
  value       = module.cos.cos_key_map
}

output "bucket_to_instance_map" {
  description = "Maps bucket names to instance ids and api keys"
  value       = module.cos.bucket_to_instance_map
}

##############################################################################

##############################################################################
# Main Outputs
##############################################################################

output "vpc_map" {
  description = "VPC Map"
  value       = module.vpc_map.value
}

##############################################################################

##############################################################################
# Security Group Outputs
##############################################################################

output "security_group_map" {
  description = "Map of Security Group Components"
  value       = module.security_group_map.value
}

output "security_group_rules_map" {
  description = "Map of all security group rules"
  value       = module.security_group_rules_map.value
}

##############################################################################

##############################################################################
# Service Authorization Outputs
##############################################################################

output "service_authorizations" {
  description = "Map of service authorizations to create"
  value       = module.service_authorizations.authorizations
}

##############################################################################

##############################################################################
# VPE outputs
##############################################################################

output "vpe_services" {
  description = "Map of VPE services to be created. Currently only COS is supported."
  value       = module.vpe.vpe_services
}

output "vpe_gateway_map" {
  description = "Map of gateways to be created"
  value       = module.vpe.vpe_gateway_map
}

output "vpe_subnet_reserved_ip_map" {
  description = "Map of reserved subnet ips for vpes"
  value       = module.vpe.vpe_subnet_reserved_ip_map
}


##############################################################################

##############################################################################
# VPN Gateway Outputs
##############################################################################

output "vpn_gateway_map" {
  description = "Map of VPN Gateways with VPC data"
  value       = module.vpn.vpn_gateway_map
}

##############################################################################


##############################################################################
# Bastion VSI Outputs
##############################################################################

output "bastion_vsi_map" {
  description = "Map of Bastion Host VSI deployments"
  value       = module.bastion_vsi_map.value
}

##############################################################################

##############################################################################
# App ID Outputs
##############################################################################

output "appid_redirect_urls" {
  description = "List of redirect urls from teleport VSI names"
  value       = module.appid.redirect_urls
}

##############################################################################

##############################################################################
# VSI Outputs
##############################################################################

output "vsi_images_map" {
  description = "Map of VSI vsi_image_map"
  value       = module.vsi.vsi_image_map
}

output "vsi_map" {
  description = "Map of VSI for creation"
  value       = module.vsi.vsi_map
}

output "ssh_keys" {
  description = "List of SSH keys with resource group ID added"
  value       = module.vsi.ssh_key_list
}

##############################################################################

##############################################################################
# VSI Outputs
##############################################################################

output "f5_vsi_map" {
  description = "Map of VSI deployments"
  value       = module.f5.f5_vsi_map
}

output "f5_template_map" {
  description = "Map of template data for f5 deployments"
  value       = module.f5_cloud_init
}

##############################################################################
