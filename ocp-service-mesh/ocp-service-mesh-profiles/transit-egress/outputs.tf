##############################################################################
# Transit Egress profiles
##############################################################################

output "egress_on_transit_nodes" {
  description = "Egress gateway located on transit nodes."
  value = {
    enabled        = true
    haAntiAffinity = true
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
  }
}
