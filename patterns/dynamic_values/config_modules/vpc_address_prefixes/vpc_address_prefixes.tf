##############################################################################
# Variables
##############################################################################

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter.. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. VPC names must begin with a letter."
  type        = list(string)

  validation {
    error_message = "VPCs names can only be a maximum of 16 characters and can only contain letters, numbers, and - characters. Names must also begin with a letter and end with a letter or number."
    condition = length([
      for name in var.vpcs :
      name if length(name) > 16 || !can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
    ]) == 0
  }
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

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map of address prefixes by zone."
  value = {
    # for each network
    for network in var.vpc_list :
    (network) => {
      for zone in [1, 2, 3] :
      "zone-${zone}" => (
        # If adding edge and is edge
        network == var.vpc_list[0] && var.add_edge_vpc
        ? ["10.${4 + zone}.0.0/16"]
        # If not adding edge and is management
        : network == var.vpcs[0] && var.create_f5_network_on_management_vpc && zone == 1
        ? ["10.${4 + zone}.0.0/16", "10.${zone}0.10.0/24", "10.10.30.0/24"]
        : network == var.vpcs[0] && var.create_f5_network_on_management_vpc
        ? ["10.${4 + zone}.0.0/16", "10.${zone}0.10.0/24"]
        # default to empty
        : []
      )
    }
  }
}

##############################################################################
