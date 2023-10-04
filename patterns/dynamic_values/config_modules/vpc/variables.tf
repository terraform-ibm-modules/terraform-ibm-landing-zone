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

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter.. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter."
  type        = list(string)
}

variable "vpc_list" {
  description = "List of VPCs"
  type        = list(string)
}

variable "add_edge_vpc" {
  description = "Create an edge VPC. This VPC will be dynamically added to the list of VPCs in `var.vpcs`. Conflicts with `create_f5_network_on_management_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
}

variable "create_f5_network_on_management_vpc" {
  description = "Set up bastion on management VPC. This value conflicts with `add_edge_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
}

variable "use_teleport" {
  description = "Use teleport"
  type        = bool
}

variable "use_f5" {
  description = "Use F5"
  type        = bool
}

variable "bastion_vpc_name" {
  description = "Name of VPC where Bastion VSI will be provisioned"
  type        = string
}

variable "add_cluster_encryption_key" {
  description = "Add encryption key for ROKS cluster."
  type        = bool
}

variable "add_ibm_cloud_internal_rules" {
  description = "Add default network ACL rules to VPC"
  type        = bool
}

variable "add_vpc_connectivity_rules" {
  description = "Add connectivity rules across any subnet within VPC"
  type        = bool
}

variable "prepend_ibm_rules" {
  description = "Allow to prepend IBM rules of VPC connectivity"
  type        = bool
}

variable "f5_tiers" {
  description = "List of F5 Network tiers"
  type        = list(string)
}

variable "teleport_management_zones" {
  description = "Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value."
  type        = number

  validation {
    error_message = "Teleport Management Zones can only be 0, 1, 2, or 3."
    condition     = var.teleport_management_zones >= 0 && var.teleport_management_zones < 4
  }
}

variable "vpn_firewall_type" {
  description = "Bastion type if provisioning bastion. Can be `full-tunnel`, `waf`, or `vpn-and-waf`."
  type        = string

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

variable "provision_teleport_in_f5" {
  description = "Provision teleport VSI in `bastion` subnet tier of F5 network if able."
  type        = bool
}

##############################################################################
