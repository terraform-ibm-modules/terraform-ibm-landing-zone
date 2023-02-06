##############################################################################
# Public Ingress profiles
##############################################################################

locals {
  common_config = {
    haAntiAffinity = true
    nodeSelector = {
      name : "ibm-cloud.kubernetes.io/worker-pool-name"
      value : "edge"
    },
    tolerations = [
      {
        key : "dedicated"
        value : "edge"
        effect : "NoExecute"
      }
    ],
    service = {
      type : "LoadBalancer",
      externalTrafficPolicy : "Local"
      metadata : {
        annotations : [
          {
            name : "service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type"
            value : "public"
          }
        ],
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

  poc_config = {
    service = {
      type : "LoadBalancer",
      externalTrafficPolicy : "Local"
      metadata : {
        annotations : [
          {
            name : "service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type"
            value : "public"
          }
        ],
      }
    }
  }

  public_ingress_config_alb   = merge({ nlb = false }, local.common_config)
  public_ingress_config_nlb   = merge({ nlb = true }, local.common_config)
  public_ingress_config_final = var.vpc_lb_type == "nlb" ? local.public_ingress_config_nlb : local.public_ingress_config_alb

  poc_config_alb   = merge({ nlb = false }, local.poc_config)
  poc_config_nlb   = merge({ nlb = true }, local.poc_config)
  poc_config_final = var.vpc_lb_type == "nlb" ? local.poc_config_nlb : local.poc_config_alb

}

output "on_edge_nodes" {
  description = "Ingress gateway located on edge nodes, and exposed through a public VPC Load Balancer"
  value       = local.public_ingress_config_final
}

output "on_all_nodes" {
  description = "Ingress gateway exposed through a public VPC Load Balancer"
  value       = local.poc_config_final
}
