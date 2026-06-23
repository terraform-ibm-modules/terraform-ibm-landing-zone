##############################################################################
# Outputs
##############################################################################

output "bastion" {
  description = "Bastion allow all"
  value = [
    {
      name            = "allow-bastion-443-inbound"
      action          = "allow"
      direction       = "inbound"
      destination     = "10.0.0.0/8"
      source          = "0.0.0.0/0"
      protocol        = "tcp"
      source_port_min = 443
      source_port_max = 443
      port_min        = null
      port_max        = null
      type            = null
      code            = null
    }
  ]
}

output "f5-external" {
  description = "F5 external allow all"
  value = [
    {
      name            = "allow-f5-external-443-inbound"
      action          = "allow"
      direction       = "inbound"
      destination     = "10.0.0.0/8"
      source          = "0.0.0.0/0"
      protocol        = "tcp"
      port_min        = 443
      port_max        = 443
      source_port_min = null
      source_port_max = null
      type            = null
      code            = null
    }
  ]
}

##############################################################################
