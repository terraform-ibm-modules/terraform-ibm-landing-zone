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

variable "teleport_domain" {
  description = "Domain for teleport instance"
  type        = string
}

variable "teleport_vsi" {
  description = "A list of teleport vsi deployments"

  # vsi name validation
  validation {
    condition     = length(distinct([for name in flatten(var.teleport_vsi[*].name) : name])) == length(flatten(var.teleport_vsi[*].name))
    error_message = "Duplicate teleport_vsi name. Please provide unique teleport_vsi names."
  }
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "redirect_urls" {
  description = "List of teleport appid redirect urls"
  value = [
    for vsi_group in var.teleport_vsi :
    "https://${var.prefix}-${vsi_group.name}.${var.teleport_domain}:3080/v1/webapi/oidc/callback"
  ]
}

##############################################################################