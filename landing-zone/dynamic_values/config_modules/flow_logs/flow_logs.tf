##############################################################################
# Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "vpc_modules" {
  description = "VPC modules"
}

variable "vpcs" {
  description = "Direct reference to VPC variable"
}

##############################################################################

##############################################################################
# Flow Logs Map
##############################################################################

module "flow_logs_map" {
  source         = "../list_to_map"
  key_name_field = "prefix"
  list = [
    for vpc_network in var.vpcs :
    {
      prefix         = vpc_network.prefix                           # Set prefix to vpc prefic
      vpc_id         = var.vpc_modules[vpc_network.prefix].vpc_id   # Set vpc name
      bucket         = vpc_network.flow_logs_bucket_name            # Get COS bucket name
      resource_group = lookup(vpc_network, "resource_group", null)  # Get resource Grou[]
    } if lookup(vpc_network, "flow_logs_bucket_name", null) != null # Only if flow logs bucket name is not null
  ]
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map of flow logs instance to be created"
  value       = module.flow_logs_map.value
}

##############################################################################