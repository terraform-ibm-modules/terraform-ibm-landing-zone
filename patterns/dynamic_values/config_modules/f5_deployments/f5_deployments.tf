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

variable "f5_resource_group" {
  description = "Name of F5 resource group"
  type        = string
}

variable "f5_zones" {
  description = "List of F5 Teleport zones."
  type        = list(number)

  validation {
    error_message = "F5 Teleport Zones must either have a length of 0 or a length of 3."
    condition     = length(var.f5_zones) == 0 || length(var.f5_zones) == 3
  }

  validation {
    error_message = "Zones must be [1, 2, 3] or empty."
    condition = length(var.f5_zones) == 0 ? true : length([
      for zone in [1, 2, 3] :
      true if index(var.f5_zones, zone) + 1 == zone
    ]) == 3
  }
}

variable "f5_vpc_name" {
  description = "Name of the VPC where F5 will be provisioned"
  type        = string
}

variable "f5_network_tiers" {
  description = "List of network tiers for F5 Deplotment"
  type        = list(string)
}

variable "f5_image_name" {
  description = "Image name for f5 deployments. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`]."
  type        = string

  validation {
    error_message = "Invalid F5 image name. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`,`f5-bigip-16-1-3-2-0-0-4-ltm-1slot`,`f5-bigip-16-1-3-2-0-0-4-all-1slot`,`f5-bigip-17-0-0-1-0-0-4-ltm-1slot`,`f5-bigip-17-0-0-1-0-0-4-all-1slot`]."
    condition     = var.f5_image_name == null ? true : contains(["f5-bigip-15-1-5-1-0-0-14-all-1slot", "f5-bigip-15-1-5-1-0-0-14-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-all-1slot", "f5-bigip-16-1-3-2-0-0-4-ltm-1slot", "f5-bigip-16-1-3-2-0-0-4-all-1slot", "f5-bigip-17-0-0-1-0-0-4-ltm-1slot", "f5-bigip-17-0-0-1-0-0-4-all-1slot"], var.f5_image_name)
  }
}

variable "f5_instance_profile" {
  description = "F5 vsi instance profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
}

variable "hostname" {
  description = "The F5 BIG-IP hostname"
  type        = string
}

variable "domain" {
  description = "The F5 BIG-IP domain name"
  type        = string
}

variable "enable_f5_management_fip" {
  description = "Enable F5 management interface floating IP. Conflicts with `enable_f5_external_fip`, VSI can only have one floating IP per instance."
  type        = bool
}

variable "enable_f5_external_fip" {
  description = "Enable F5 external interface floating IP. Conflicts with `enable_f5_management_fip`, VSI can only have one floating IP per instance."
  type        = bool
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "List of F5 VSI deployments"
  value = [
    for instance in var.f5_zones :
    {
      vpc_name                        = var.f5_vpc_name
      f5_image_name                   = var.f5_image_name
      machine_type                    = var.f5_instance_profile
      domain                          = var.domain
      hostname                        = var.hostname
      enable_management_floating_ip   = var.enable_f5_management_fip
      enable_external_floating_ip     = var.enable_f5_external_fip
      resource_group                  = var.f5_resource_group
      ssh_keys                        = ["ssh-key"]
      name                            = "f5-zone-${instance}"
      primary_subnet_name             = "f5-management-zone-${instance}"
      boot_volume_encryption_key_name = "${var.prefix}-vsi-volume-key"
      security_groups                 = ["f5-management-sg"]
      secondary_subnet_names = [
        for subnet in var.f5_network_tiers :
        "${subnet}-zone-${instance}" if subnet != "f5-management"
      ]
      secondary_subnet_security_group_names = [
        for subnet in var.f5_network_tiers :
        {
          group_name     = "${subnet}-sg"
          interface_name = "${var.prefix}-${var.f5_vpc_name}-${subnet}-zone-${instance}"
        } if subnet != "f5-management"
      ]
    }
  ]
}

##############################################################################
