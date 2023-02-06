##############################################################################
# Pilot Runtime profiles
##############################################################################

output "on_private_nodes" {
  description = "Place the istio pilot pods on private nodes"
  value = {
    pod : {
      nodeSelector = {
        name : "ibm-cloud.kubernetes.io/worker-pool-name"
        value : "default"
      }
    }
  }
}
