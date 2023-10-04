output "vsi_data" {
  description = "Details of the VSI including name, id, zone, and primary ipv4 address, VPC Name, and floating IP."
  value       = local.env.security_groups
}
