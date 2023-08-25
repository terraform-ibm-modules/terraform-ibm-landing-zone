##############################################################################
# Output Variables
##############################################################################

output "config" {
  description = "Output configuration as encoded JSON"
  value = module.landing_zone.config
}
