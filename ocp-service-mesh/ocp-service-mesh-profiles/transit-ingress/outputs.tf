##############################################################################
# Transit Ingress profiles
##############################################################################

locals {
  common_config = {
    haAntiAffinity = true
    sDNLB = {
      createSDNLB : true
      additionalPorts : var.additional_sdnlb_ports
    },
    nodeSelector = {
      name : "ibm-cloud.kubernetes.io/worker-pool-name"
      value : "transit"
    },
    tolerations = [
      {
        key : "dedicated"
        value : "transit"
        effect : "NoExecute"
      }
    ]
    service = {
      type : "LoadBalancer",
      externalTrafficPolicy : "Local"
      metadata : {
        labels : [
          {
            name : "app"
            value : var.label
          },
          {
            name : "istio"
            value : var.label
          }
        ]
      }
    }
  }

  # sdnlb_transit_ingress_gateway
  sdnlb_cse_proxy_disabled = {
    createSDNLB : true
    enableCSEProxy : false
    cseProxyIstioLabel : var.label
    additionalPorts : var.additional_sdnlb_ports
  }
  cse_proxy_disabled_config           = merge(local.common_config, { sDNLB = local.sdnlb_cse_proxy_disabled })
  sdnlb_transit_ingress_gateway_alb   = merge({ nlb = false }, local.cse_proxy_disabled_config)
  sdnlb_transit_ingress_gateway_nlb   = merge({ nlb = true }, local.cse_proxy_disabled_config)
  sdnlb_transit_ingress_gateway_final = var.vpc_lb_type == "nlb" ? local.sdnlb_transit_ingress_gateway_nlb : local.sdnlb_transit_ingress_gateway_alb

  # sdnlb_transit_ingress_gateway_cse_proxy_enabled
  sdnlb_cse_proxy_enabled = {
    createSDNLB : true
    enableCSEProxy : true
    cseProxyIstioLabel : var.label
    additionalPorts : var.additional_sdnlb_ports
  }
  cse_proxy_enabled_config                              = merge(local.common_config, { sDNLB = local.sdnlb_cse_proxy_enabled })
  sdnlb_transit_ingress_gateway_cse_proxy_enabled_alb   = merge({ nlb = false }, local.cse_proxy_enabled_config)
  sdnlb_transit_ingress_gateway_cse_proxy_enabled_nlb   = merge({ nlb = true }, local.cse_proxy_enabled_config)
  sdnlb_transit_ingress_gateway_cse_proxy_enabled_final = var.vpc_lb_type == "nlb" ? local.sdnlb_transit_ingress_gateway_cse_proxy_enabled_nlb : local.sdnlb_transit_ingress_gateway_cse_proxy_enabled_alb

}

output "sdnlb_transit_ingress_gateway" {
  description = "Ingress gateway located on transit nodes, and exposed through an sDNLB"
  value       = local.sdnlb_transit_ingress_gateway_final
}

output "sdnlb_transit_ingress_gateway_cse_proxy_enabled" {
  description = "Ingress gateway located on transit nodes, and exposed through an sDNLB with CSE Proxy enabled."
  value       = local.sdnlb_transit_ingress_gateway_cse_proxy_enabled_final
}
