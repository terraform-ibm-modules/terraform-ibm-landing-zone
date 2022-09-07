##############################################################################
# Landing Zone
##############################################################################

module "landing_zone" {
  source               = "../../patterns/vsi"
  prefix               = var.prefix
  region               = var.region
  ibmcloud_api_key     = var.ibmcloud_api_key
  ssh_public_key       = var.ssh_key
  override_json_string = var.override_json_string
}
