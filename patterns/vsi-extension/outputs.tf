output "vsi_data" {
  description = "Details of the VSI including name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = module.vsi
}

output "next_steps_text" {
  value       = "Your Virtual Server Instances are ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Virtual Server Instances"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/infrastructure/compute/vs"
  description = "Primary URL"
}


output "next_step_secondary_label" {
  value       = "Expose app to internet"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-access-public-app"
  description = "Secondary URL"
}