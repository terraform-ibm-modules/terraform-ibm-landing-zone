##############################################################################
# Outputs
##############################################################################

output "default_vpc_rules" {
  description = "List of default vpc rules"
  value = [{
    name        = "allow-ibm-inbound"
    action      = "allow"
    direction   = "inbound"
    destination = "10.0.0.0/8"
    source      = "161.26.0.0/16"
    tcp = {
      port_min = null
      port_max = null
    }
    },
    {
      name        = "allow-all-network-inbound"
      action      = "allow"
      direction   = "inbound"
      destination = "10.0.0.0/8"
      source      = "10.0.0.0/8"
      tcp = {
        port_min = null
        port_max = null
      }
    },
    {
      name        = "allow-all-outbound"
      action      = "allow"
      direction   = "outbound"
      destination = "0.0.0.0/0"
      source      = "0.0.0.0/0"
      tcp = {
        port_min = null
        port_max = null
      }
  }]
}

output "bastion" {
  description = "Bastion allow all"
  value = [
    {
      name        = "allow-bastion-443-inbound"
      action      = "allow"
      direction   = "inbound"
      destination = "10.0.0.0/8"
      source      = "0.0.0.0/0"
      tcp = {
        source_port_min = 443
        source_port_max = 443
      }
    }
  ]
}

output "f5-external" {
  description = "F5 external allow all"
  value = [
    {
      name        = "allow-f5-external-443-inbound"
      action      = "allow"
      direction   = "inbound"
      destination = "10.0.0.0/8"
      source      = "0.0.0.0/0"
      tcp = {
        port_min = 443
        port_max = 443
      }
    }
  ]
}

##############################################################################
