##############################################################################
# Variable
##############################################################################

variable "f5_teleport_zones" {
  description = "List of F5 Teleport zones."
  type        = list(number)

  validation {
    error_message = "F5 Teleport Zones must either have a length of 0 or a length of 3."
    condition     = length(var.f5_teleport_zones) == 0 || length(var.f5_teleport_zones) == 3
  }

  validation {
    error_message = "Zones must be [1, 2, 3] or empty."
    condition = length(var.f5_teleport_zones) == 0 ? true : length([
      for zone in [1, 2, 3] :
      true if index(var.f5_teleport_zones, zone) + 1 == zone
    ]) == 3
  }
}

variable "f5_tiers" {
  description = "List of F5 tiers being used by deployment."
  type        = list(string)
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  # List of CIDR for workload subnets
  workload_subnets = [
    "10.10.10.0/24",
    "10.20.10.0/24",
    "10.30.10.0/24",
    "10.40.10.0/24",
    "10.50.10.0/24",
    "10.60.10.0/24"
  ]
}

##############################################################################


##############################################################################
# Outputs
##############################################################################

output "management_bastion_rules" {
  description = "List of rules for F5 Management security group when provisioning bastion tier."
  value = flatten([
    for zone in var.f5_teleport_zones :
    [
      for port in [22, 443] :
      {
        name      = "${zone}-inbound-${port}"
        direction = "inbound"
        source    = "10.${4 + zone}.${1 + index(var.f5_tiers, "bastion")}0.0/24"
        tcp = {
          port_max = port
          port_min = port
        }
      }
    ]
  ])
}

output "external_rules" {
  description = "List of rules for F5 External interface security group."
  value = [
    {
      name      = "allow-inbound-443"
      direction = "inbound"
      source    = "0.0.0.0/0"
      tcp = {
        port_max = 443
        port_min = 443
      }
    }
  ]
}

output "workload_rules" {
  description = "List of rules for F5 workload interface."
  value = [
    for subnet in local.workload_subnets :
    {
      name      = "allow-workload-subnet-${index(local.workload_subnets, subnet) + 1}"
      source    = subnet
      direction = "inbound"
      tcp = {
        port_max = 443
        port_min = 443
      }
    }
  ]
}

output "bastion_rules" {
  description = "List of rules for F5 Bastion interface."
  value = flatten([
    for zone in [1, 2, 3] :
    [
      for ports in [[3023, 3025], [3080, 3080]] :
      {
        name      = "${zone}-inbound-${ports[0]}"
        direction = "inbound"
        source    = "10.${4 + zone}.${1 + index(concat(var.f5_tiers, ["bastion"]), "bastion")}0.0/24"
        tcp = {
          port_min = ports[0]
          port_max = ports[1]
        }
      }
    ]
  ])
}

output "bastion_vsi_rules" {
  description = "Allow rules for Bastion VSI"
  value = [
    {
      name      = "allow-inbound-443"
      direction = "inbound"
      source    = "0.0.0.0/0"
      tcp = {
        port_max = 443
        port_min = 443
      }
    },
    {
      name      = "allow-all-outbound"
      direction = "outbound"
      source    = "0.0.0.0/0"
      tcp = {
        port_max = null
        port_min = null
      }
    }
  ]
}

##############################################################################
