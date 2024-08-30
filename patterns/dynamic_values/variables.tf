##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources that is prepended to resources that are provisioned. Must begin with a lowercase letter and end with a lowercase letter or number. Must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters. Prefixes must end with a letter or number and be 16 or fewer characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter.. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter."
  type        = list(string)
  default     = ["management", "workload"]

  validation {
    error_message = "VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. Names must also begin with a letter and end with a letter or number."
    condition = length([
      for name in var.vpcs :
      name if length(name) > 16 || !can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
    ]) == 0
  }
}

variable "add_ibm_cloud_internal_rules" {
  description = "Add default network ACL rules to VPC"
  type        = bool
  default     = true
}

variable "add_vpc_connectivity_rules" {
  description = "Add connectivity rules across any subnet within VPC"
  type        = bool
  default     = true
}

variable "prepend_ibm_rules" {
  description = "Allow to prepend IBM rules of VPC connectivity"
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Key Management Variables
##############################################################################

variable "hs_crypto_instance_name" {
  description = "Specify the name of the Hyper Protect Crypto Services instance for key management. Leave as null to use the Key Protect service."
  type        = string
  default     = null
}

variable "hs_crypto_resource_group" {
  description = "For Hyper Protect Crypto Services (HPCS), specify the name of the resource group for the instance in `hs_crypto_instance_name`. Leave as null for the `Default` resource group or if not using HPCS."
  type        = string
  default     = null
}

variable "existing_kms_instance_name" {
  description = "Specify the name of an existing Key Management Service instance for key management. Leave as null to deploy a new Key Protect service."
  type        = string
  default     = null
}

variable "existing_kms_resource_group" {
  description = "For using an existing Key Management Service (KMS), specify the name of the resource group for the instance in `existing_kms_instance_name`. Leave as null for the `Default` resource group or if not using an existing KMS."
  type        = string
  default     = null
}

variable "existing_kms_endpoint_type" {
  description = "The endpoint type to use when accessing the existing KMS instance, default is `public`."
  type        = string
  default     = "public"

  validation {
    error_message = "Endpoint type can only be `public` or `private`."
    condition     = contains(["public", "private", null], var.existing_kms_endpoint_type)
  }
}

##############################################################################


##############################################################################
# COS Variables
##############################################################################

variable "use_random_cos_suffix" {
  description = "Add a random 8 character string to the end of each cos instance, bucket, and key."
  type        = bool
  default     = false
}

variable "existing_cos_instance_name" {
  description = "Specify the name of an existing Cloud Object Storage (COS) instance that can be used for new buckets, if required."
  type        = string
  default     = null
}

variable "existing_cos_resource_group" {
  description = "For using an existing Cloud Object Storage (COS) instance, specify the name of the resource group for the instance in `existing_cos_instance_name`. Leave as null for the `Default` resource group or if not using an existing COS."
  type        = string
  default     = null
}

variable "existing_cos_endpoint_type" {
  description = "The endpoint type to use when accessing the existing COS instance, default is `public`."
  type        = string
  default     = "public"

  validation {
    error_message = "Endpoint type can only be `public` or `private`."
    condition     = contains(["public", "private", null], var.existing_cos_endpoint_type)
  }
}

variable "use_existing_cos_for_vpc_flowlogs" {
  description = "Set to `true` if you have chosen to include an `existing_cos_instance_name` and wish to use that instance for your VPC Flow Log bucket. This setting will only be used if an `existing_cos_instance_name` is supplied."
  type        = bool
  default     = false
}

variable "use_existing_cos_for_atracker" {
  description = "Set to `true` if you have chosen to include an `existing_cos_instance_name` and wish to use that instance for your Activity Tracker (atracker) routing. This setting will only be used if an `existing_cos_instance_name` is supplied."
  type        = bool
  default     = false
}

##############################################################################


##############################################################################
# Virtual Server Variables
##############################################################################

variable "add_vsi_volume_encryption_key" {
  description = "Add encryption key for VSI creation"
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable "add_cluster_encryption_key" {
  description = "Add encryption key for ROKS cluster."
  type        = bool
  default     = true
}

##############################################################################

##############################################################################
# Atracker Variables
##############################################################################
variable "add_atracker_route" {
  description = "Add atracker route, with global events. If true there will also be a COS bucket added to config to be target"
  type        = bool
  default     = true
}

##############################################################################

##############################################################################
# F5 Variables
##############################################################################

variable "add_edge_vpc" {
  description = "Create an edge VPC. This VPC will be dynamically added to the list of VPCs in `var.vpcs`. Conflicts with `create_f5_network_on_management_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
  default     = false
}

variable "create_f5_network_on_management_vpc" {
  description = "Set up bastion on management VPC. This value conflicts with `add_edge_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
  default     = false
}

variable "provision_teleport_in_f5" {
  description = "Provision teleport VSI in `bastion` subnet tier of F5 network if able."
  type        = bool
  default     = false
}

variable "vpn_firewall_type" {
  description = "Bastion type if provisioning bastion. Can be `full-tunnel`, `waf`, or `vpn-and-waf`."
  type        = string
  default     = null

  validation {
    error_message = "Bastion type must be `full-tunnel`, `waf`, `vpn-and-waf` or `null`."
    condition = (
      # if bastion type is null
      var.vpn_firewall_type == null
      # return true
      ? true
      # otherwise check list
      : contains(["full-tunnel", "waf", "vpn-and-waf"], var.vpn_firewall_type)
    )
  }

}

variable "f5_image_name" {
  description = "Image name for f5 deployments. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`]."
  type        = string
  default     = "f5-bigip-17-0-0-1-0-0-4-all-1slot"

  validation {
    error_message = "Invalid F5 image name. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`,`f5-bigip-16-1-3-2-0-0-4-ltm-1slot`,`f5-bigip-16-1-3-2-0-0-4-all-1slot`,`f5-bigip-17-0-0-1-0-0-4-ltm-1slot`,`f5-bigip-17-0-0-1-0-0-4-all-1slot`]."
    condition     = var.f5_image_name == null ? true : contains(["f5-bigip-15-1-5-1-0-0-14-all-1slot", "f5-bigip-15-1-5-1-0-0-14-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-all-1slot", "f5-bigip-16-1-3-2-0-0-4-ltm-1slot", "f5-bigip-16-1-3-2-0-0-4-all-1slot", "f5-bigip-17-0-0-1-0-0-4-ltm-1slot", "f5-bigip-17-0-0-1-0-0-4-all-1slot"], var.f5_image_name)
  }
}

variable "f5_instance_profile" {
  description = "F5 vsi instance profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
  default     = "cx2-4x8"
}

variable "hostname" {
  description = "The F5 BIG-IP hostname"
  type        = string
  default     = "f5-ve-01"
}

variable "domain" {
  description = "The F5 BIG-IP domain name"
  type        = string
  default     = "f5-ve-01"
}

variable "app_id" {
  description = "The terraform application id for phone_home_url_metadata"
  type        = string
  default     = "null"
}

variable "enable_f5_management_fip" {
  description = "Enable F5 management interface floating IP. Conflicts with `enable_f5_external_fip`, VSI can only have one floating IP per instance."
  type        = bool
  default     = false
}

variable "enable_f5_external_fip" {
  description = "Enable F5 external interface floating IP. Conflicts with `enable_f5_management_fip`, VSI can only have one floating IP per instance."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# Teleport VSI Variables
##############################################################################

variable "teleport_management_zones" {
  description = "Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value."
  type        = number
  default     = 0

  validation {
    error_message = "Teleport Management Zones can only be 0, 1, 2, or 3."
    condition     = var.teleport_management_zones >= 0 && var.teleport_management_zones < 4
  }
}

variable "appid_resource_group" {
  description = "Resource group for existing appid instance. This value is ignored if a new instance is created."
  type        = string
  default     = null
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
