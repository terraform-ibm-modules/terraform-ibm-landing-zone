##############################################################################
# Output Variables
##############################################################################

output "prefix" {
  description = "The prefix that is associated with all resources"
  value       = var.prefix
}

output "resource_group_names" {
  description = "List of resource groups names used within landing zone."
  value       = module.landing_zone.resource_group_names
}

output "resource_group_data" {
  description = "List of resource groups data used within landing zone."
  value       = module.landing_zone.resource_group_data
}

output "vpc_names" {
  description = "A list of the names of the VPC"
  value       = module.landing_zone.vpc_names
}

output "vpc_data" {
  description = "List of VPC data"
  value       = module.landing_zone.vpc_data
}

output "vpc_resource_list" {
  description = "List of VPC with VSI and Cluster deployed on the VPC."
  value       = module.landing_zone.vpc_resource_list
}

output "subnet_data" {
  description = "List of Subnet data created"
  value       = module.landing_zone.subnet_data
}

output "transit_gateway_name" {
  description = "The name of the transit gateway"
  value       = module.landing_zone.transit_gateway_name
}

output "transit_gateway_data" {
  description = "Created transit gateway data"
  value       = module.landing_zone.transit_gateway_data
}

output "ssh_public_key" {
  description = "The string value of the ssh public key"
  value       = var.ssh_public_key
}

output "ssh_key_data" {
  description = "List of SSH key data"
  value       = module.landing_zone.ssh_key_data
}

output "cos_data" {
  description = "List of Cloud Object Storage instance data"
  value       = module.landing_zone.cos_data
}

output "cos_bucket_data" {
  description = "List of data for COS buckets created"
  value       = module.landing_zone.cos_bucket_data
}

output "vpn_data" {
  description = "List of VPN data"
  value       = module.landing_zone.vpn_data
}

output "cluster_names" {
  description = "List of create cluster names"
  value       = module.landing_zone.cluster_names
}

output "cluster_data" {
  description = "List of cluster data"
  value       = module.landing_zone.cluster_data
}

output "workload_cluster_id" {
  description = "The id of the worload cluster. If the cluster name does not exactly match the prefix-workload-cluster pattern it will be null."
  value       = module.landing_zone.workload_cluster_id
}

output "workload_cluster_rg_id" {
  description = "The resource group id of the workload cluster. If the cluster name does not exactly match the prefix-workload-cluster pattern it will be null."
  value       = module.landing_zone.workload_cluster_rg_id
}

output "workload_cluster_rg_name" {
  description = "The resource group name of the workload cluster. If the cluster name does not exactly match the prefix-workload-cluster pattern it will be null."
  value       = module.landing_zone.workload_cluster_rg_name
}

output "workload_cluster_name" {
  description = "The name of the worload cluster. If the cluster name does not exactly match the prefix-workload-cluster pattern it will be null."
  value       = module.landing_zone.workload_cluster_name
}

output "management_cluster_id" {
  description = "The id of the management cluster. If the cluster name does not exactly match the prefix-management-cluster pattern it will be null."
  value       = module.landing_zone.management_cluster_id
}

output "management_cluster_name" {
  description = "The name of the management cluster. If the cluster name does not exactly match the prefix-management-cluster pattern it will be null."
  value       = module.landing_zone.management_cluster_name
}

output "workload_cluster_ingress_hostname" {
  description = "The hostname assigned for the Workload cluster ingress subdomain, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.ingress_hostname
      if can(regex("workload", name))
    ])
  )
}

output "management_cluster_ingress_hostname" {
  description = "The hostname assigned for the Management cluster ingress subdomain, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.ingress_hostname
      if can(regex("management", name))
    ])
  )
}

output "workload_cluster_private_service_endpoint_url" {
  description = "The private service endpoint URL of the Workload cluster, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.private_service_endpoint_url
      if can(regex("workload", name))
    ])
  )
}

output "management_cluster_private_service_endpoint_url" {
  description = "The private service endpoint URL of the Management cluster, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.private_service_endpoint_url
      if can(regex("management", name))
    ])
  )
}

output "workload_cluster_public_service_endpoint_url" {
  description = "The public service endpoint URL of the Workload cluster, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.public_service_endpoint_url
      if can(regex("workload", name))
    ])
  )
}

output "management_cluster_public_service_endpoint_url" {
  description = "The public service endpoint URL of the Management cluster, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.public_service_endpoint_url
      if can(regex("management", name))
    ])
  )
}

output "workload_cluster_console_url" {
  description = "Workload cluster console URL, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.cluster_console_url
      if can(regex("workload", name))
    ])
  )
}

output "management_cluster_console_url" {
  description = "Management cluster console URL, if not then null."
  value = one(
    flatten([
      for name, cluster in module.landing_zone.cluster_data :
      cluster.cluster_console_url
      if can(regex("management", name))
    ])
  )
}

output "key_management_name" {
  description = "Name of key management service"
  value       = module.landing_zone.key_management_name
}

output "key_management_crn" {
  description = "CRN for KMS instance"
  value       = module.landing_zone.key_management_crn
}

output "key_management_guid" {
  description = "GUID for KMS instance"
  value       = module.landing_zone.key_management_guid
}

output "key_rings" {
  description = "Key rings created by module"
  value       = module.landing_zone.key_rings
}

output "key_map" {
  description = "Map of ids and keys for keys created"
  value       = module.landing_zone.key_map
}

output "vpc_dns" {
  description = "List of VPC DNS details for each of the VPCs."
  value       = module.landing_zone.vpc_dns
}

##############################################################################

##############################################################################
# Output Configuration
##############################################################################

output "config" {
  description = "Output configuration as encoded JSON"
  value       = data.external.format_output.result.data
}

##############################################################################

##############################################################################
# Schematics Output
##############################################################################

output "schematics_workspace_id" {
  description = "ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics"
  value       = var.IC_SCHEMATICS_WORKSPACE_ID
}
##############################################################################
