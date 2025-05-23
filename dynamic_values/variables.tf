##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
}


##############################################################################

##############################################################################
# VSI Variables
##############################################################################

variable "vsi" {
  description = "Direct reference to VSI variable"
}

variable "ssh_keys" {
  description = "Direct reference to SSH keys"
}

##############################################################################

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_modules" {
  description = "Direct reference to VPC modules"
}

variable "vpcs" {
  description = "Direct reference to vpcs variable"
}

##############################################################################

##############################################################################
# Cluster Variables
##############################################################################

variable "clusters" {}

##############################################################################

##############################################################################
# COS Variables
##############################################################################

variable "cos" {
  description = "Direct reference to cos variable"
}

variable "cos_data_source" {
  description = "COS Data Resources"
}

variable "cos_resource" {
  description = "Created COS instance resources"
}

variable "cos_resource_keys" {
  description = "Create COS resource keys"
}

variable "suffix" {
  description = "Suffix for cos"
}

##############################################################################

##############################################################################
# Security Groups Variables
##############################################################################

variable "security_groups" {
  description = "Security groups variable"
}

##############################################################################

##############################################################################
# Service Authorization Variables
##############################################################################

variable "resource_groups" {
  description = "Reference to compiled resource group locals"
}

variable "key_management" {
  description = "Reference to key management variable"
}

variable "key_management_guid" {
  description = "Key Management GUID"
}

variable "key_management_key_map" {
  description = "Key management key IDs"
}

##############################################################################

##############################################################################
# VPE Variables
##############################################################################

variable "virtual_private_endpoints" {
  description = "Direct reference to Virtual Private Endpoints variable"
}

##############################################################################

##############################################################################
# VPN Gateway Variables
##############################################################################

variable "vpn_gateways" {
  description = "VPN Gateways Variable Value"
}

##############################################################################

##############################################################################
# Bastion VSI Variables
##############################################################################

variable "bastion_vsi" {
  description = "Direct reference to Bastion VSI variable"
}

##############################################################################

##############################################################################
# App Id Variables
##############################################################################

variable "appid" {
  description = "Direct reference to App ID variable"
}

variable "appid_resource" {
  description = "Created App ID instance resource"
}

variable "appid_data" {
  description = "App ID data resource"
}

variable "teleport_domain" {
  description = "Teleport instance domain"
}

##############################################################################

##############################################################################
# F5 VSI Variables
##############################################################################

variable "f5_vsi" {
  description = "Direct reference to VSI variable"
}

variable "f5_template_data" {
  description = "Direct reference to template data"
}

##############################################################################

##############################################################################
# Service Authorization Variables
##############################################################################

variable "skip_kms_block_storage_s2s_auth_policy" {
  description = "Direct reference to kms block storage variable"
}

variable "skip_kms_kube_s2s_auth_policy" {
  description = "Do not create a kube to kms auth policy"
}

variable "skip_all_s2s_auth_policies" {
  description = "Direct reference to s2s authorization variable"
}

variable "atracker_cos_bucket" {
  description = "Direct reference to atracker to cos variable"
}
##############################################################################
