##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = "no-compute"

  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "us-south"
}

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

##############################################################################
# VPC Variables
##############################################################################

variable "network_cidr" {
  description = "Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning."
  type        = string
  default     = "10.0.0.0/8"
}

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. VPC names must begin with a lowercase letter and end with a lowercase letter or number."
  type        = list(string)
  default     = ["management", "workload"]

  validation {
    error_message = "VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. Names must also begin with a lowercase letter and end with a lowercase letter or number."
    condition = length([
      for name in var.vpcs :
      name if length(name) > 16 || !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
    ]) == 0
  }
}

variable "enable_transit_gateway" {
  description = "Create transit gateway"
  type        = bool
  default     = true
}

variable "add_atracker_route" {
  description = "Atracker can only have one route per zone. use this value to disable or enable the creation of atracker route"
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Key Management Variables
##############################################################################

variable "hs_crypto_instance_name" {
  description = "Optionally, you can bring you own Hyper Protect Crypto Service instance for key management. If you would like to use that instance, add the name here. Otherwise, leave as null"
  type        = string
  default     = null
}

variable "hs_crypto_resource_group" {
  description = "If you're using Hyper Protect Crypto services in a resource group other than `Default`, provide the name here."
  type        = string
  default     = null
}

##############################################################################


##############################################################################
# COS Variables
##############################################################################

variable "use_random_cos_suffix" {
  description = "Add a random 8 character string to the end of each cos instance, bucket, and key."
  type        = bool
  default     = true
}

##############################################################################

##############################################################################
# Secrets Manager Variables
##############################################################################

variable "create_secrets_manager" {
  description = "Create a secrets manager deployment."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# Security and Compliance Center
##############################################################################

variable "enable_scc" {
  description = "Enable creation of SCC resources"
  type        = bool
  default     = false
}

variable "scc_cred_name" {
  description = "The name of the credential"
  type        = string
  default     = "slz-cred"

  validation {
    error_message = "SCC Credential Name must be 255 or fewer characters."
    condition     = var.scc_cred_name == null ? true : can(regex("^[a-zA-Z0-9-\\.\\*,_\\s]*$", var.scc_cred_name)) && length(var.scc_cred_name) <= 255
  }
}

variable "scc_cred_description" {
  description = "Description of SCC Credential"
  type        = string
  default     = "This credential is used for SCC."

  validation {
    error_message = "SCC Credential Description must be 255 or fewer characters."
    condition     = var.scc_cred_description == null ? true : can(regex("^[a-zA-Z0-9-\\._,\\s]*$", var.scc_cred_description)) && length(var.scc_cred_description) <= 255
  }
}

variable "scc_collector_description" {
  description = "Description of SCC Collector"
  type        = string
  default     = "collector description"

  validation {
    error_message = "SCC Collector Description must be 1000 or fewer characters."
    condition     = var.scc_collector_description == null ? true : can(regex("^[a-zA-Z0-9-\\._,\\s]*$", var.scc_collector_description)) && length(var.scc_collector_description) <= 1000
  }
}

variable "scc_scope_description" {
  description = "Description of SCC Scope"
  type        = string
  default     = "IBM-schema-for-configuration-collection"

  validation {
    error_message = "SCC Scope Description must be 255 or fewer characters."
    condition     = var.scc_scope_description == null ? true : can(regex("^[a-zA-Z0-9-\\._,\\s]*$", var.scc_scope_description)) && length(var.scc_scope_description) <= 255
  }
}

variable "scc_scope_name" {
  description = "The name of the SCC Scope"
  type        = string
  default     = "scope"

  validation {
    error_message = "SCC Scope Name must be 50 or fewer characters."
    condition     = var.scc_scope_name == null ? true : can(regex("^[a-zA-Z0-9-\\.,_\\s]*$", var.scc_scope_name)) && length(var.scc_scope_name) <= 50
  }
}

##############################################################################

##############################################################################
# s2s variables
##############################################################################

variable "add_kms_block_storage_s2s" {
  description = "Whether to create a service-to-service authorization between block storage and the key management service."
  type        = bool
  default     = true
}

##############################################################################

##############################################################################
# Override JSON
##############################################################################

variable "override" {
  description = "Override default values with custom JSON template. This uses the file `override.json` to allow users to create a fully customized environment."
  type        = bool
  default     = false
}

variable "override_json_string" {
  description = "Override default values with custom JSON. Any value here other than an empty string will override all other configuration changes."
  type        = string
  default     = ""
}

##############################################################################
