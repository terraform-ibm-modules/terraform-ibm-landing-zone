output "prefix" {
  description = "The prefix that is associated with all resources"
  value       = var.prefix
}

output "vpc_names" {
  description = "A list of the names of the VPC"
  value       = module.landing_zone.vpc_names
}

output "vsi_names" {
  description = "A list of the vsis names provisioned within the VPCs"
  value       = module.landing_zone.vsi_names
}

output "transit_gateway_name" {
  description = "The name of the transit gateway"
  value       = module.landing_zone.transit_gateway_name
}

output "ssh_public_key" {
  description = "The string value of the ssh public key"
  value       = var.ssh_public_key
}

output "fip_vsi" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. This list only contains instances with a floating IP attached."
  value       = module.landing_zone.fip_vsi_data
}

output "vsi_list" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.landing_zone.vsi_data
}

output "schematics_workspace_id" {
  descritpion = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics"
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}

##############################################################################
# Output Configuration
##############################################################################

output "config" {
  description = "Output configuration as encoded JSON"
  value       = data.external.format_output.result.data
}

##############################################################################
