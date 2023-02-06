##############################################################################
# Outputs
##############################################################################

output "istio_ingressgateway_hostname" {
  description = "Each control plane's istio ingress gateway load balancer hostname"
  value = {
    for k, v in data.kubernetes_service.istio_ingressgateway : k => v.status[0].load_balancer[0].ingress[0]
  }
}

output "ingress_subdomains" {
  description = "Ingress Subdomains along with the secret name to enable TLS for the respective subdomains"
  value       = length(module.ingress_subdomain) > 0 ? module.ingress_subdomain : null
}