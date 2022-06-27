##############################################################################
# Cloud Init Output
##############################################################################

output "cloud_init" {
  description = "Description of my output"
  value       = data.template_cloudinit_config.cloud_init.rendered
}

##############################################################################