##############################################################################
# basic-with-mtls (not part of the compliance framework)
##############################################################################

locals {
  control_plane_name_basic = var.control_plane_name != null ? var.control_plane_name : "basic-with-mtls"
}

output "basic_with_mtls" {
  description = <<EOB
  NB: This profile is for very basic POCs and is not part of the compliance framework.
  Profile with:
  1. One INGRESS gateway deployment (consuming from public VPC LB)
    - No node selectors or tolerations so gateway pods assigned across all nodes (so ensure all nodes have public access)
    - Auto-scaling enabled (min 3 -> max 10 replicas)
  2. One EGRESS gateway deployment
    - No node selectors or tolerations so gateway pods assigned across all nodes (so ensure all nodes have public access)
    - Auto-scaling enabled (min 3 -> max 10 replicas)
  3. Access logging turned on
  4. mTLS enabled (data and control planes)
  EOB
  value = {
    name                = local.control_plane_name_basic,
    namespace           = var.control_plane_namespace,
    enrolled_namespaces = var.enrolled_namespaces,
    gateways = {
      ingress = module.public_ingress_config.on_all_nodes
    }
  }
}

##############################################################################
# public_ingress_egress_no_transit
##############################################################################

locals {
  control_plane_name_1 = var.control_plane_name != null ? var.control_plane_name : "gateways-on-edge-pool"
}

output "public_ingress_egress_no_transit" {
  description = <<EOB
  Profile with:
  1. One public INGRESS gateway deployment (consuming from public VPC LB)
    - Gateway pods located on edge worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  2. One public EGRESS gateway deployment
    - Gateway pods located on edge worker pool (with public internet access through the public gateway).
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti affinity - eg: forcing pods to spread across workers
    - Egress allow-list enforced - egress allows only to endpoints configured as istio ServiceEntries
  3. Access logging turned on, JSON format
  4. mTLS enabled (data and control planes)
  5. Istio Pilot pods located on private worker pool
  EOB
  value = {
    name                = local.control_plane_name_1,
    namespace           = var.control_plane_namespace,
    enrolled_namespaces = var.enrolled_namespaces,
    runtime             = module.pilot_config.on_private_nodes
    proxy               = module.proxy_config.with_json_access_logging
    gateways = {
      egress  = module.public_egress_config.on_edge_nodes,
      ingress = module.public_ingress_config.on_edge_nodes
    }
  }
}

##############################################################################
# public_ingress_egress_with_sdnlb_transit
##############################################################################

locals {
  control_plane_name_2 = var.control_plane_name != null ? var.control_plane_name : "gateways-on-edge-transit-pool"
}

output "public_ingress_egress_with_sdnlb_transit" {
  description = <<EOB
  Profile with:
  1. One public INGRESS gateway deployment (consuming from public VPC LB)
    - Gateway pods located on edge worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  2. One transit INGRESS gateway deployment (consuming from sDNLB)
    - Gateway pods located on transit worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  3. One public EGRESS gateway deployment
    - Gateway pods located on edge worker pool (with public internet access through the public gateway).
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti affinity - eg: forcing pods to spread across workers
    - Egress allow-list enforced - egress allows only to endpoints configured as istio ServiceEntries
  4. One transit EGRESS gateway deployment (to sit in front of the VPEs in transit)
    - Allows deep packet inspection if needed + gives further controls on what pods can make a call to what VPE IP
    - Gateway pods located on transit worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  5. Access logging turned on, JSON format
  6. mTLS enabled (data and control planes)
  7. Istio Pilot pods located on private worker pool
  EOB
  value = {
    name                = local.control_plane_name_2,
    namespace           = var.control_plane_namespace,
    enrolled_namespaces = var.enrolled_namespaces,
    runtime             = module.pilot_config.on_private_nodes
    proxy               = module.proxy_config.with_json_access_logging
    gateways = {
      egress  = module.public_egress_config.on_edge_nodes,
      ingress = module.public_ingress_config.on_edge_nodes,
      additionalIngress = {
        sdnlb-transit-ingress = module.transit_ingress_config.sdnlb_transit_ingress_gateway
      },
      additionalEgress = {
        transit-egress = module.transit_egress_config.egress_on_transit_nodes
      }
    }
  }
}

##############################################################################
# public_ingress_egress_with_sdnlb_transit_cse_proxy_enabled
##############################################################################

locals {
  control_plane_name_3 = var.control_plane_name != null ? var.control_plane_name : "gateways-on-edge-transit-pool-cse-proxy"
}

output "public_ingress_egress_with_sdnlb_transit_cse_proxy_enabled" {
  description = <<EOB
  Profile with:
  1. One public INGRESS gateway deployment (consuming from public VPC LB)
    - Gateway pods located on edge worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  2. One transit INGRESS gateway deployment (consuming from sDNLB)
    - Gateway pods located on transit worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  3. One public EGRESS gateway deployment
    - Gateway pods located on edge worker pool (with public internet access through the public gateway).
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti affinity - eg: forcing pods to spread across workers
    - Egress allow-list enforced - egress allows only to endpoints configured as istio ServiceEntries
  4. One transit EGRESS gateway deployment (to sit in front of the VPEs in transit)
    - Allows deep packet inspection if needed + gives further controls on what pods can make a call to what VPE IP
    - Gateway pods located on transit worker pool
    - Auto-scaling enabled (min 3 -> max 10 replicas)
    - HA anti-affinity enabled - eg: forcing pods to spread across workers
  5. Configures CSE Proxy Envoy Filter
  6. Access logging turned on, JSON format
  7. mTLS enabled (data and control planes)
  8. Istio Pilot pods located on private worker pool
  EOB
  value = {
    name                = local.control_plane_name_3,
    namespace           = var.control_plane_namespace,
    enrolled_namespaces = var.enrolled_namespaces,
    runtime             = module.pilot_config.on_private_nodes
    proxy               = module.proxy_config.with_json_access_logging
    gateways = {
      egress  = module.public_egress_config.on_edge_nodes,
      ingress = module.public_ingress_config.on_edge_nodes,
      additionalIngress = {
        sdnlb-transit-ingress-cse-proxy-enabled = module.transit_ingress_config.sdnlb_transit_ingress_gateway_cse_proxy_enabled
      }
    }
  }
}
