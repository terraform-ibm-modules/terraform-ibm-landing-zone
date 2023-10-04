##############################################################################
# Variables
##############################################################################

variable "create_f5_network_on_management_vpc" {
  description = "Set up bastion on management VPC. This value conflicts with `add_edge_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
}

variable "use_teleport" {
  description = "Use teleport"
  type        = bool
}

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter.. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter."
  type        = list(string)
}

variable "vpc_list" {
  description = "List of VPCs"
  type        = list(string)
}

variable "f5_tiers" {
  description = "List of F5 Network tiers"
  type        = list(string)
}

variable "add_edge_vpc" {
  description = "Create an edge VPC. This VPC will be dynamically added to the list of VPCs in `var.vpcs`. Conflicts with `create_f5_network_on_management_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
}

variable "teleport_management_zones" {
  description = "Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value."
  type        = number

  validation {
    error_message = "Teleport Management Zones can only be 0, 1, 2, or 3."
    condition     = var.teleport_management_zones >= 0 && var.teleport_management_zones < 4
  }
}


##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  vpc_subnet_tiers = {
    for network in var.vpc_list :
    (network) => {
      zone-1 = (
        # If f5 on management and use teleport and management vpc
        var.create_f5_network_on_management_vpc && network == var.vpcs[0]
        # f5-tiers vsi vpn
        ? concat(var.f5_tiers, ["vsi", "vpn"])
        # if edge and edge
        : var.add_edge_vpc && network == var.vpc_list[0]
        # f5 tiers
        ? var.f5_tiers
        # if teleport on management and management
        : var.teleport_management_zones > 0 && network == var.vpcs[0]
        ? ["vsi", "vpe", "vpn", "bastion"]
        # if management add vpn
        : network == var.vpcs[0]
        ? ["vsi", "vpe", "vpn"]
        : ["vsi", "vpe"]
      )
      zone-2 = (
        # If f5 on management and use teleport and management vpc
        var.create_f5_network_on_management_vpc && network == var.vpcs[0]
        # F5 tiers and vsi
        ? concat(var.f5_tiers, ["vsi"])
        # if edge and edge
        : var.add_edge_vpc && network == var.vpc_list[0]
        # F5 tiers
        ? var.f5_tiers
        # If teleport and zones >= 2
        : var.teleport_management_zones > 0 && network == var.vpcs[0] && var.teleport_management_zones >= 2
        ? ["vsi", "vpe", "bastion"]
        : ["vsi", "vpe"]
      )
      zone-3 = (
        # If f5 on management and use teleport and management vpc
        var.create_f5_network_on_management_vpc && network == var.vpcs[0]
        # F5 tiers and vsi
        ? concat(var.f5_tiers, ["vsi"])
        # if edge and edge
        : var.add_edge_vpc && network == var.vpc_list[0]
        # F5 tiers
        ? var.f5_tiers
        # If teleport and zones >= 2
        : var.teleport_management_zones > 0 && network == var.vpcs[0] && var.teleport_management_zones >= 3
        ? ["vsi", "vpe", "bastion"]
        : ["vsi", "vpe"]
      )
    }
  }
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map of networks and corresponding subnet tiers"
  value       = local.vpc_subnet_tiers
}

##############################################################################
