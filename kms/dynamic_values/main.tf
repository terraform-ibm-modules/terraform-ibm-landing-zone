##############################################################################
# Variables
##############################################################################

variable "use_hs_crypto" {
  description = "Use HS Crypto"
  type        = bool
  default     = null
}

variable "use_data" {
  description = "Use Data"
  type        = bool
  default     = null
}

variable "hpcs_data" {
  description = "hpcs instance data"
  default     = null
}

variable "kms_data" {
  description = "kms data instance data"
  default     = null
}

variable "kms_resource" {
  description = "kms resource instance data"
  default     = null
}

variable "keys" {
  description = "Copy of keys variable"
  default     = []
}

variable "name" {
  description = "Name of the kms instance"
  default     = null
}

##############################################################################

##############################################################################
# Dynamic Values
##############################################################################

locals {
  # Get key management type
  key_management_type = var.use_hs_crypto == true ? "hs-crypto" : var.use_data == true ? "data" : var.name == null ? null : "resource"
  # Get GUID
  key_management_guid = (
    local.key_management_type == "hs-crypto"
    ? var.hpcs_data[0].guid
    : local.key_management_type == "data"
    ? var.kms_data[0].guid
    : var.name == null
    ? null
    : var.kms_resource[0].guid
  )
  # Get CRN
  key_management_crn = (
    local.key_management_type == "hs-crypto"
    ? var.hpcs_data[0].crn
    : local.key_management_type == "data"
    ? var.kms_data[0].crn
    : var.name == null
    ? null
    : var.kms_resource[0].crn
  )
  # Keys to create (if CRN is not provided)
  key_management_keys_to_create = {
    for encryption_key in var.keys :
    (encryption_key.name) => encryption_key if try(coalesce(encryption_key.crn, "-"), "-") == "-"
  }

  # Existing keys with CRN provided)
  key_management_keys_existing = {
    for encryption_key in var.keys :
    (encryption_key.name) => encryption_key if try(coalesce(encryption_key.crn, "-"), "-") != "-"
  }

  # Rings
  key_rings = distinct([
    for encryption_key in var.keys :
    encryption_key.key_ring if encryption_key.key_ring != null
  ])

  # Policies
  key_management_key_policies = {
    for encryption_key in var.keys :
    (encryption_key.name) => encryption_key if lookup(encryption_key, "policies", null) != null
  }
}

##############################################################################


##############################################################################
# Outputs
##############################################################################

output "key_management_type" {
  description = "Type of key management to use"
  value       = local.key_management_type
}

output "guid" {
  description = "GUID of Key Management to use"
  value       = local.key_management_guid
}

output "crn" {
  description = "CRN of Key Management to use"
  value       = local.key_management_crn
}

output "existing_keys" {
  description = "Map of existing keys with CRNs"
  value       = local.key_management_keys_existing
}

output "keys_to_create" {
  description = "Map of keys to be created"
  value       = local.key_management_keys_to_create
}

output "key_rings" {
  description = "Key rings map"
  value       = local.key_rings
}

output "policies" {
  description = "Key policies"
  value       = local.key_management_key_policies
}

##############################################################################
