##############################################################################
# Appid Outputs
##############################################################################

locals {
  appid_instance = (
    local.create_bastion_host == false # if no bastion host
    ? null                             # null
    : local.create_appid == "data"
    ? data.ibm_resource_instance.appid
    : ibm_resource_instance.appid
  )
}

output "appid_name" {
  description = "Name of the appid instance used."
  value       = local.appid_instance == null ? null : local.appid_instance[0].name
}

output "appid_key_names" {
  description = "List of appid key names created"
  value = [
    for instance in ibm_resource_key.appid_key :
    instance.name
  ]
}

output "appid_redirect_urls" {
  description = "List of appid redirect urls"
  value       = ibm_appid_redirect_urls.urls[*].urls
}

##############################################################################

##############################################################################
# Atracker Outputs
##############################################################################

output "atracker_target_name" {
  description = "Name of atracker target"
  value       = local.valid_atracker_region ? ibm_atracker_target.atracker_target[0].name : null
}

output "atracker_route_name" {
  description = "Name of atracker route"
  value       = local.valid_atracker_region && var.atracker.add_route == true ? tolist(ibm_atracker_route.atracker_route[*].name)[0] : null
}

##############################################################################

##############################################################################
# Bastion Host Outputs
##############################################################################

output "bastion_host_names" {
  description = "List of bastion host names"
  value = flatten([
    for instance in keys(module.bastion_host) :
    module.bastion_host[instance].list[*].name
  ])
}

##############################################################################

##############################################################################
# Cluster Outputs
##############################################################################

output "cluster_names" {
  description = "List of create cluster names"
  value = [
    for cluster in module.cluster :
    cluster.cluster_name
  ]
}

##############################################################################

##############################################################################
# COS Outputs
##############################################################################

output "cos_names" {
  description = "List of Cloud Object Storage instance names"
  value = flatten([
    [
      for instance in data.ibm_resource_instance.cos :
      instance.name
    ],
    [
      for instance in ibm_resource_instance.cos :
      instance.name
    ]
  ])
}

output "cos_key_names" {
  description = "List of names for created COS keys"
  value = [
    for instance in ibm_resource_key.key :
    instance.name
  ]
}

output "cos_bucket_names" {
  description = "List of names for COS buckets creaed"
  value = [
    for instance in ibm_cos_bucket.buckets :
    instance.bucket_name
  ]
}

##############################################################################

##############################################################################
# F5 Outputs
##############################################################################

output "f5_host_names" {
  description = "List of bastion host names"
  value = flatten([
    for instance in keys(module.f5_vsi) :
    module.f5_vsi[instance].list[*].name
  ])
}

##############################################################################

##############################################################################
# VPC Outputs
##############################################################################

output "vpc_names" {
  description = "List of VPC names"
  value = [
    for network in module.vpc :
    network.vpc_name
  ]
}

output "subnet_names" {
  description = "List of Subnet names created"
  value = flatten([
    for network in module.vpc :
    network.subnet_zone_list[*].name
  ])
}

##############################################################################

##############################################################################
# Resource Group Outputs
##############################################################################

output "resource_group_names" {
  description = "List of resource groups names used within landing zone."
  value       = keys(local.resource_groups)
}

##############################################################################

##############################################################################
# Secrets Manager Outputs
##############################################################################

output "secrets_manager_name" {
  description = "Name of secrets manager instance"
  value       = var.secrets_manager.use_secrets_manager ? ibm_resource_instance.secrets_manager[0].name : null
}

##############################################################################

##############################################################################
# Security Group Outputs
##############################################################################

output "security_group_names" {
  description = "List of security group names"
  value = [
    for group in ibm_is_security_group.security_group :
    group.name
  ]
}

##############################################################################

##############################################################################
# Service Authorization Names
##############################################################################

output "service_authorization_names" {
  description = "List of service authorization names"
  value       = keys(ibm_iam_authorization_policy.policy)
}

##############################################################################

##############################################################################
# SSH Key Outputs
##############################################################################

output "ssh_key_names" {
  description = "List of SSH key names"
  value       = module.ssh_keys.ssh_keys[*].name
}

##############################################################################

##############################################################################
# Transit Gateway Outputs
##############################################################################

output "transit_gateway_name" {
  description = "Name of created transit gateway"
  value       = var.enable_transit_gateway ? ibm_tg_gateway.transit_gateway[0].name : null
}

##############################################################################

##############################################################################
# VSI Outputs
##############################################################################

output "vsi_names" {
  description = "List of VSI names"
  value = flatten([
    for group in module.vsi :
    group.list[*].name
  ])
}

output "fip_vsi_data" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. This list only contains instances with a floating IP attached."
  value = flatten([
    [
      for group in keys(local.vsi_map) :
      [
        for deployment in module.vsi[group].fip_list :
        merge(deployment, {
          vpc_name = [
            for network in keys(local.vpc_map) :
            module.vpc[network].vpc_name if module.vpc[network].vpc_id == deployment.vpc_id
          ][0]
        })
      ]
    ]
  ])
}

output "vsi_data" {
  description = "A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value = flatten([
    [
      for group in keys(local.vsi_map) :
      [
        for deployment in module.vsi[group].list :
        merge(deployment, {
          vpc_name = [
            for network in keys(local.vpc_map) :
            module.vpc[network].vpc_name if module.vpc[network].vpc_id == deployment.vpc_id
          ][0]
        })
      ]
    ]
  ])
}

##############################################################################

##############################################################################
# VPE Variables
##############################################################################

output "vpe_gateway_names" {
  description = "VPE gateway names"
  value = [
    for gateway in ibm_is_virtual_endpoint_gateway.endpoint_gateway :
    gateway.name
  ]
}

##############################################################################

##############################################################################
# VPN Names
##############################################################################

output "vpn_names" {
  description = "List of VPN names"
  value = [
    for gateway in ibm_is_vpn_gateway.gateway :
    gateway.name
  ]
}

##############################################################################
