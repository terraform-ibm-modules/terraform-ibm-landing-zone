##############################################################################
# Network ACL
##############################################################################

locals {
  cluster_rules = [
    # Cluster Rules
    {
      name        = "roks-create-worker-nodes-inbound"
      action      = "allow"
      source      = "161.26.0.0/16"
      destination = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "inbound"
      tcp         = null
      udp         = null
      icmp        = null
    },
    {
      name        = "roks-create-worker-nodes-outbound"
      action      = "allow"
      destination = "161.26.0.0/16"
      source      = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "outbound"
      tcp         = null
      udp         = null
      icmp        = null
    },
    {
      name        = "roks-nodes-to-service-inbound"
      action      = "allow"
      source      = "166.8.0.0/14"
      destination = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "inbound"
      tcp         = null
      udp         = null
      icmp        = null
    },
    {
      name        = "roks-nodes-to-service-outbound"
      action      = "allow"
      destination = "166.8.0.0/14"
      source      = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "outbound"
      tcp         = null
      udp         = null
      icmp        = null
    },
    # App Rules
    {
      name        = "allow-app-incoming-traffic-requests"
      action      = "allow"
      source      = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      destination = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "inbound"
      tcp = {
        source_port_min = 30000
        source_port_max = 32767
      }
      udp  = null
      icmp = null
    },
    {
      name        = "allow-app-outgoing-traffic-requests"
      action      = "allow"
      source      = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      destination = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "outbound"
      tcp = {
        port_min = 30000
        port_max = 32767
      }
      udp  = null
      icmp = null
    },
    {
      name        = "allow-lb-incoming-traffic-requests"
      action      = "allow"
      source      = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      destination = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "inbound"
      tcp = {
        port_min = 443
        port_max = 443
      }
      udp  = null
      icmp = null
    },
    {
      name        = "allow-lb-outgoing-traffic-requests"
      action      = "allow"
      source      = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      destination = var.network_cidr != null ? var.network_cidr : "0.0.0.0/0"
      direction   = "outbound"
      tcp = {
        source_port_min = 443
        source_port_max = 443
      }
      udp  = null
      icmp = null
    }
  ]

  # ACL Objects                                                                                    
  acl_object = {
    for network_acl in var.network_acls :
    network_acl.name => {
      rules = flatten([
        [
          # These rules cannot be added in a conditional operator due to inconsistant typing
          # This will add all cluster rules if the acl object contains add_cluster rules
          for rule in local.cluster_rules :
          rule if network_acl.add_cluster_rules == true
        ],
        network_acl.rules
      ])
    }
  }
}

resource "ibm_is_network_acl" "network_acl" {
  for_each       = local.acl_object
  name           = "${var.prefix}-${each.key}" // already has name of vpc in each.key
  vpc            = ibm_is_vpc.vpc.id
  resource_group = var.resource_group_id

  # Create ACL rules
  dynamic "rules" {
    for_each = each.value.rules
    content {
      name        = rules.value.name
      action      = rules.value.action
      source      = rules.value.source
      destination = rules.value.destination
      direction   = rules.value.direction

      dynamic "tcp" {
        for_each = (
          # if rules null
          rules.value.tcp == null
          # empty array
          ? []
          # otherwise check each possible field against how many of the values are
          # equal to null and only include rules where one of the values is not null
          # this allows for patterns to include `tcp` blocks for conversion to list
          # while still not creating a rule. default behavior would force the rule to
          # be included if all indiviual values are set to null
          : length([
            for value in ["port_min", "port_max", "source_port_min", "source_port_min"] :
            true if lookup(rules.value["tcp"], value, null) == null
          ]) == 4
          ? []
          : [rules.value]
        )
        content {
          port_min        = lookup(rules.value.tcp, "port_min", null)
          port_max        = lookup(rules.value.tcp, "port_max", null)
          source_port_min = lookup(rules.value.tcp, "source_port_min", null)
          source_port_max = lookup(rules.value.tcp, "source_port_min", null)
        }
      }

      dynamic "udp" {
        for_each = (
          # if rules null
          rules.value.udp == null
          # empty array
          ? []
          # otherwise check each possible field against how many of the values are
          # equal to null and only include rules where one of the values is not null
          # this allows for patterns to include `udp` blocks for conversion to list
          # while still not creating a rule. default behavior would force the rule to
          # be included if all indiviual values are set to null
          : length([
            for value in ["port_min", "port_max", "source_port_min", "source_port_min"] :
            true if lookup(rules.value["udp"], value, null) == null
          ]) == 4
          ? []
          : [rules.value]
        )
        content {
          port_min        = lookup(rules.value.udp, "port_min", null)
          port_max        = lookup(rules.value.udp, "port_max", null)
          source_port_min = lookup(rules.value.udp, "source_port_min", null)
          source_port_max = lookup(rules.value.udp, "source_port_min", null)
        }
      }

      dynamic "icmp" {
        for_each = (
          # if rules null
          rules.value.icmp == null
          # empty array
          ? []
          # otherwise check each possible field against how many of the values are
          # equal to null and only include rules where one of the values is not null
          # this allows for patterns to include `udp` blocks for conversion to list
          # while still not creating a rule. default behavior would force the rule to
          # be included if all indiviual values are set to null
          : length([
            for value in ["code", "type"] :
            true if lookup(rules.value["icmp"], value, null) == null
          ]) == 2
          ? []
          : [rules.value]
        )
        content {
          type = rules.value.icmp.type
          code = rules.value.icmp.code
        }
      }
    }
  }
}

##############################################################################
