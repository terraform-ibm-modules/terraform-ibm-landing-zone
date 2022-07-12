##############################################################################
# Rules
##############################################################################

locals {

  allow_ibm_inbound = [{
    name      = "allow-ibm-inbound"
    source    = "161.26.0.0/16"
    direction = "inbound"
  }]

  allow_network_inbound_outbound = [
    for direction in ["inbound", "outbound"] :
    [
      {
        name      = "allow-vpc-${direction}"
        source    = "10.0.0.0/8"
        direction = direction
      }
    ]
  ]

  no_port_netork_ibm_rules = flatten([
    local.allow_ibm_inbound,
    local.allow_network_inbound_outbound
  ])

  add_port_network_ibm_rules = [
    for rule in local.no_port_netork_ibm_rules :
    merge(rule, {
      tcp = {
        port_min = null
        port_max = null
      }
    })
  ]

  ibm_service_port_rules = [
    for port in [53, 80, 443] :
    {
      name      = "allow-ibm-tcp-${port}-outbound"
      source    = "161.26.0.0/16"
      direction = "outbound"
      tcp = {
        port_min = port
        port_max = port
      }
    }
  ]
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "rules" {
  description = "List of VSI default security group rules"
  value = concat(
    local.no_port_netork_ibm_rules,
    local.ibm_service_port_rules
  )
}

output "all_tcp_rules" {
  description = "List of VSI default security group rules"
  value = concat(
    local.add_port_network_ibm_rules,
    local.ibm_service_port_rules
  )
}

##############################################################################