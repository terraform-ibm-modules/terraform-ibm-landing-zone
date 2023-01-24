##############################################################################
# Outputs
##############################################################################

output "cluster_id" {
  description = "ID of cluster created"
  value       = module.ocp_base.cluster_id
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = module.ocp_base.cluster_name
}

output "cluster_crn" {
  description = "CRN for the created cluster"
  value       = module.ocp_base.cluster_crn
}

output "workerpools" {
  description = "Worker pools created"
  value       = module.ocp_base.workerpools
}

output "ocp_version" {
  description = "Openshift Version of the cluster"
  value       = module.ocp_base.ocp_version
}

output "cos_crn" {
  description = "The IBM Cloud Object Storage instance CRN used to back up the internal registry in the OCP cluster."
  value       = module.ocp_base.cos_crn
}

output "vpc_id" {
  description = "ID of the clusters VPC"
  value       = module.ocp_base.vpc_id
}

output "region" {
  description = "Region cluster is deployed in"
  value       = var.region
}

output "resource_group_id" {
  description = "Resource group ID the cluster is deployed in"
  value       = module.ocp_base.resource_group_id
}

output "ingress_hostname" {
  description = "The hostname that was assigned to the OCP clusters Ingress subdomain."
  value       = module.ocp_base.ingress_hostname
}

output "private_service_endpoint_url" {
  description = "Private service endpoint URL"
  value       = module.ocp_base.private_service_endpoint_url
}

output "public_service_endpoint_url" {
  description = "Public service endpoint URL"
  value       = module.ocp_base.public_service_endpoint_url
}

##############################################################################
