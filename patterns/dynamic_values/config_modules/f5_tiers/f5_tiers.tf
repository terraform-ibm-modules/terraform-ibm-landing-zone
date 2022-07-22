##############################################################################
# Variables
##############################################################################

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

variable "vpn_firewall_types" {
  description = "Map containing subnet tiers for each VPN firewall type"
  type = object({
    full-tunnel = list(string)
    waf         = list(string)
    vpn-and-waf = list(string)
  })
}

variable "provision_teleport_in_f5" {
  description = "Provision teleport VSI in `bastion` subnet tier of F5 network if able."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  # Bastion if provisioning teleport in f5, otherwise empty array
  bastion_subnet_tiers = var.provision_teleport_in_f5 == true ? ["bastion"] : []
  # List of network tiers, if firewall type is null empty, otherwsie list of tiers
  f5_network_tiers = var.vpn_firewall_type == null ? [] : var.vpn_firewall_types[var.vpn_firewall_type]
  vpn_tiers        = var.vpn_firewall_type == "waf" || var.vpn_firewall_type == null ? [] : ["vpn-1", "vpn-2"]
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "List of subnet tiers for F5 Network"
  value = concat(
    local.vpn_tiers,            # static vpn tiers
    local.f5_network_tiers,     # dynamic f5 tiers
    local.bastion_subnet_tiers, # dynamic bastion tiers
    ["vpe"]                     # vpe tier
  )
}

##############################################################################
