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

variable "name" {
  description = "Name of Key Management instance"
  type        = string
}

variable "resource_group" {
  description = "Name of Key Management resource group"
  type        = string
}

variable "use_hs_crypto" {
  description = "Use hscypto for key management"
  type        = bool
}

variable "add_vsi_volume_encryption_key" {
  description = "Add encryption key for VSI creation"
  type        = bool
}

variable "add_cluster_encryption_key" {
  description = "Add encryption key for ROKS cluster."
  type        = bool
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  cluster_key = var.add_cluster_encryption_key == true ? ["roks"] : []
  volume_key  = var.add_vsi_volume_encryption_key == true ? ["vsi-volume"] : []
  key_list = concat(
    ["slz", "atracker"],
    local.cluster_key,
    local.volume_key
  )
  keys = [
    for service in local.key_list :
    {
      name     = "${var.prefix}-${service}-key"
      root_key = true
      key_ring = "${var.prefix}-slz-ring"
    }
  ]
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "Key management instance value"
  value = {
    name           = var.name
    resource_group = var.resource_group
    use_hs_crypto  = var.use_hs_crypto
    keys           = local.keys
  }
}

##############################################################################