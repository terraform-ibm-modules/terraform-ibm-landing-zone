##############################################################################
# Output Variables
##############################################################################
output "config" {
  description = "Output configuration as encoded JSON"
  value       = module.landing_zone.config
 }

output "next_steps_text" {
  value       = module.landing_zone.next_steps_text
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = module.landing_zone.next_step_primary_label
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.landing_zone.next_step_primary_url
  description = "Primary URL"
}


output "next_step_secondary_label" {
  value       = module.landing_zone.next_step_secondary_label
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = module.landing_zone.next_step_secondary_url
  description = "Secondary URL"
}