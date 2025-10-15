##############################################################################
# Output Variables
##############################################################################

output "config" {
  description = "Output configuration as encoded JSON"
  value       = module.landing_zone.config
}

output "next_steps_text" {
  value       = "Your Virtual Server Instances are ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "View jump-box instance"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/infrastructure/compute/vs/${var.region}~${module.landing_zone.vsi_list[0].id}/overview"
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "View workload-server instance"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/infrastructure/compute/vs/${var.region}~${module.landing_zone.vsi_list[1].id}/overview"
  description = "Secondary URL"
}



# output "next_step_vsi_urls" {
#   description = "Map of VSI names to their IBM Cloud console URLs"
#   value = {
#     for vsi in module.landing_zone.vsi_list :
#     vsi.name => "https://cloud.ibm.com/infrastructure/compute/vs/${var.region}~${vsi.id}/overview"
#   }
# }
