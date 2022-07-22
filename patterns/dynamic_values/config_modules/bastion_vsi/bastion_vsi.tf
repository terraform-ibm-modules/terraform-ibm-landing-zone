##############################################################################
# Variables
##############################################################################

variable "bastion_zone_list" {
  description = "List of numerical zones where bastion vsi will be provisioned."
  type        = list(number)

  validation {
    error_message = "Bastion zone list can only contain 0, 1, 2, or 3 zones."
    condition     = length(var.bastion_zone_list) < 4 && length(var.bastion_zone_list) >= 0
  }

  validation {
    error_message = "Each zone in the list must be unique."
    condition     = length(distinct(var.bastion_zone_list)) == length(var.bastion_zone_list)
  }

  validation {
    error_message = "Bastion zones can only be 1, 2, or 3."
    condition = (
      length(var.bastion_zone_list) == 0 # if length is 0
      ? true                             # true
      : length([
        # Return true for array values that are not 1, 2, 3
        for zone in var.bastion_zone_list :
        true if !contains([1, 2, 3], zone)
      ]) == 0 # length should be zero
    )
  }
}

variable "vpc_name" {
  description = "Name of VPC where VSI will be provisioned"
  type        = string
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters. Prefixes must end with a letter or number and be 16 or fewer characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "teleport_instance_profile" {
  description = "Machine type for Teleport VSI instances. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
}

variable "teleport_vsi_image_name" {
  description = "Teleport VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images."
  type        = string
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "List of teleport vsi to create"
  value = [
    for instance in var.bastion_zone_list :
    {
      name                            = "bastion-${instance}"
      vpc_name                        = var.vpc_name
      subnet_name                     = "bastion-zone-${instance}"
      resource_group                  = "${var.prefix}-${var.vpc_name}-rg"
      ssh_keys                        = ["ssh-key"]
      image_name                      = var.teleport_vsi_image_name
      machine_type                    = var.teleport_instance_profile
      boot_volume_encryption_key_name = "${var.prefix}-vsi-volume-key"
      security_groups                 = ["bastion-vsi-sg"]
    }
  ]
}

##############################################################################
