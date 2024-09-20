##############################################################################
# Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters. Prefixes must end with a letter or number and be 16 or fewer characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "vpc_list" {
  description = "List of VPCs for pattern"
  type        = list(string)
}

variable "hs_crypto_resource_group" {
  description = "Name of hscrypto resource group"
  type        = list(string)

  validation {
    error_message = "HS Crypto resource group can only have 0 or 1 element."
    condition     = length(var.hs_crypto_resource_group) == 0 || length(var.hs_crypto_resource_group) == 1
  }
}

variable "appid_resource_group" {
  description = "Name of appid resource group"
  type        = list(string)

  validation {
    error_message = "App ID resource group can only have 0 or 1 element."
    condition     = length(var.appid_resource_group) == 0 || length(var.appid_resource_group) == 1
  }
}

variable "existing_kms_resource_group" {
  description = "Name of an existing KMS instance resource group"
  type        = list(string)

  validation {
    error_message = "Existing KMS instance resource group can only have 0 or 1 element."
    condition     = length(var.existing_kms_resource_group) == 0 || length(var.existing_kms_resource_group) == 1
  }
}

variable "existing_cos_resource_group" {
  description = "Name of hscrypto resource group"
  type        = list(string)

  validation {
    error_message = "Existing COS instance resource group can only have 0 or 1 element."
    condition     = length(var.existing_cos_resource_group) == 0 || length(var.existing_cos_resource_group) == 1
  }
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  # List of resource groups used by default
  resource_group_list = flatten([
    ["service"],
    var.hs_crypto_resource_group,
    var.appid_resource_group,
    var.existing_kms_resource_group,
    var.existing_cos_resource_group
  ])

  # Create reference list
  dynamic_rg_list = flatten([
    [
      "Default",
      "default",
    ],
    var.hs_crypto_resource_group,
    var.appid_resource_group,
    var.existing_kms_resource_group,
    var.existing_cos_resource_group
  ])

  # All Resource groups
  all_resource_groups = distinct(concat(local.resource_group_list, var.vpc_list))
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "List of resource groups"
  value = [
    for group in local.all_resource_groups :
    {
      name   = contains(local.dynamic_rg_list, group) ? group : "${var.prefix}-${group}-rg"
      create = contains(local.dynamic_rg_list, group) ? false : true
    }
  ]
}

##############################################################################
