##############################################################################
# VPE Variables
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
  description = "VPC region"
}

variable "virtual_private_endpoints" {
  description = "Reference to virtual_private_endpoints variable"
}

variable "vpc_modules" {
  description = "map of vpc modules"
}

variable "cos_instance_ids" {
  description = "map of COS instance IDs"
}

##############################################################################
