output "vsi_data" {
  description = "Details of the VSI including name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.vsi
}

output "next_steps_text" {
  value       = "Your Virtual Server Instance is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Virtual Server Instance"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = length(module.vsi.ids) > 0 ? "https://cloud.ibm.com/infrastructure/compute/vs" : null
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "SSH Connection Guide"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi/blob/main/solutions/quickstart/ssh_connection_guide.md"
  description = "Secondary URL"
}
