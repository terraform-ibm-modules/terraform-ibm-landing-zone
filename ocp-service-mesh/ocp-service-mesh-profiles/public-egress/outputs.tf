##############################################################################
# Egress Gateway profiles
##############################################################################

output "on_edge_nodes" {
  description = "Egress gateway located on edge nodes"
  value = {
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
    ]
  }
}
