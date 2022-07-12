##############################################################################
# Variables
##############################################################################

variable "network" {
  description = "Name of network"
  type        = string
}

variable "f5_tiers" {
  description = "List of F5 Network tiers"
  type        = list(string)
}

variable "vpc_list" {
  description = "List of VPCs"
  type        = list(string)
}

variable "use_f5" {
  description = "Use F5"
  type        = bool
}

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

variable "subnet_tiers" {
  description = "Zone to subnet tier map for a VPC"
  type = object({
    zone-1 = list(string)
    zone-2 = list(string)
    zone-3 = list(string)
  })
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map of subnet cidr by zone"
  value = {
    for zone in [1, 2, 3] :
    "zone-${zone}" => {
      for tier in var.subnet_tiers["zone-${zone}"] :
      (tier) => (
        var.vpn_firewall_type != null     # if f5 type is not null
        && var.use_f5                     # using f5
        && var.network == var.vpc_list[0] # on f5 network
        && contains(var.f5_tiers, tier)   # and is an f5 tier
      )
      ? "10.${zone + 4}.${1 + index(var.f5_tiers, tier)}0.0/24"
      : "10.${zone + (index(var.vpcs, var.network) * 3)}0.${1 + index(["vsi", "vpe", "vpn", "bastion"], tier)}0.0/24"
    }
  }
}

##############################################################################