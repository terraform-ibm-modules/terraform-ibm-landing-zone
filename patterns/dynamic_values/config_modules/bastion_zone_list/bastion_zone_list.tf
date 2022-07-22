##############################################################################
# Variables
##############################################################################

variable "provision_teleport_in_f5" {
  description = "Provision teleport VSI in `bastion` subnet tier of F5 network if able."
  type        = bool
  default     = false
}

variable "teleport_management_zones" {
  description = "Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value."
  type        = number
  default     = 0

  validation {
    error_message = "Teleport Management Zones can only be 0, 1, 2, or 3."
    condition     = var.teleport_management_zones >= 0 && var.teleport_management_zones < 4
  }
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "List of teleport zones"
  value = flatten(
    [
      # if provision teleport on f5
      var.provision_teleport_in_f5 == true
      # all three zones
      ? [1, 2, 3]
      # if not management zones
      : var.teleport_management_zones == 0
      # empty array
      ? []
      # otherwise for each zone in the range return that number +1
      : [
        for zone in range(var.teleport_management_zones) :
        zone + 1
      ]
    ]
  )
}

##############################################################################
