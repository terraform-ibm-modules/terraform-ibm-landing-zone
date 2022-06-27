##############################################################################
# Network ACL
##############################################################################

locals {
  acl_map = {
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

##############################################################################


##############################################################################
# Static Cluster Rules
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
}

##############################################################################