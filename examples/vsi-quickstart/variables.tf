##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "tf_version" {
  default     = "1.0"
  type        = string
  description = "The version of the Terraform engine that's used in the Schematics workspace."
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = "land-zone-vsi-qs"

  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "us-south"
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "network_cidr" {
  description = "Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning."
  type        = string
  default     = "10.0.0.0/8"
}

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. VPC names must begin with a lowercase letter and end with a lowercase letter or number."
  type        = list(string)
  default     = ["management", "workload"]

  validation {
    error_message = "VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. Names must also begin with a lowercase letter and end with a lowercase letter or number."
    condition = length([
      for name in var.vpcs :
      name if length(name) > 16 || !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
    ]) == 0
  }
}

variable "enable_transit_gateway" {
  description = "Create transit gateway"
  type        = bool
  default     = true
}

variable "add_atracker_route" {
  description = "Atracker can only have one route per zone. Use this value to disable or enable the creation of atracker route"
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Key Management Variables
##############################################################################

variable "hs_crypto_instance_name" {
  description = "Optionally, you can bring you own Hyper Protect Crypto Service instance for key management. If you would like to use that instance, add the name here. Otherwise, leave as null"
  type        = string
  default     = null
}

variable "hs_crypto_resource_group" {
  description = "If you're using Hyper Protect Crypto services in a resource group other than `Default`, provide the name here."
  type        = string
  default     = null
}

##############################################################################


##############################################################################
# COS Variables
##############################################################################

variable "use_random_cos_suffix" {
  description = "Add a random 8 character string to the end of each cos instance, bucket, and key."
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Virtual Server Variables
##############################################################################

variable "vsi_image_name" {
  description = "VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images."
  type        = string
  default     = "ibm-ubuntu-18-04-6-minimal-amd64-2"
}

variable "vsi_instance_profile" {
  description = "VSI image profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
  default     = "cx2-2x4"
}

variable "vsi_per_subnet" {
  description = "Number of Virtual Servers to create on each VSI subnet."
  type        = number
  default     = 1
}
variable "ssh_key" {
  type        = string
  description = "An existing ssh key name to use for this example, if unset a new ssh key will be created"
  default     = null
}
