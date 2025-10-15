##############################################################################
# Output Variables
##############################################################################

output "config" {
  description = "Output configuration as encoded JSON"
  value       = module.landing_zone.config
}

# output "next_steps_text" {
#   value       = module.landing_zone.next_steps_text
#   description = "Next steps text"
# }

# output "next_step_primary_label" {
#   value       = module.landing_zone.next_step_primary_label
#   description = "Primary label"
# }

# output "next_step_primary_url" {
#   value       = module.landing_zone.next_step_primary_url
#   description = "Primary URL"
# }


# output "next_step_secondary_label" {
#   value       = module.landing_zone.next_step_secondary_label
#   description = "Secondary label"
# }

# output "next_step_secondary_url" {
#   value       = module.landing_zone.next_step_secondary_url
#   description = "Secondary URL"
# }

output "next_step_vsi_urls" {
  description = "Map of VSI names to their IBM Cloud console URLs"
  value = {
    for vsi in module.landing_zone.vsi_list :
    vsi.name => "https://cloud.ibm.com/infrastructure/compute/vs/${var.region}~${vsi.id}/overview"
  }
}