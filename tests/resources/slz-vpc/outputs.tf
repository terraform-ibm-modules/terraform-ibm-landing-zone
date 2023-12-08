##############################################################################
# Outputs
##############################################################################

output "prefix" {
  value       = module.landing_zone.prefix
  description = "Prefix"
}

output "management_vpc_id" {
  value = lookup(
    [for vpc in module.landing_zone.vpc_data : vpc if vpc.vpc_name == "${var.prefix}-management-vpc"][0],
    "vpc_id",
  "")
  description = "Management VPC ID"
}

output "workload_vpc_id" {
  value = lookup(
    [for vpc in module.landing_zone.vpc_data : vpc if vpc.vpc_name == "${var.prefix}-workload-vpc"][0],
    "vpc_id",
  "")
  description = "Workload VPC ID"
}

# Parse the VSI KMS Key CRN
locals {
  vsi_key_map = lookup(module.landing_zone.key_map, "${var.prefix}-vsi-volume-key", "")
  vsi_key_crn = lookup(local.vsi_key_map, "crn", "")
}

output "vsi_kms_key_crn" {
  value       = local.vsi_key_crn
  description = "VSI KMS Key CRN"
}
