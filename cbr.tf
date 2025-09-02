##############################################################################
# Update existing CBR VPC network zone
##############################################################################
module "update_cbr_vpc_zone" {
  source                = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version               = "1.33.0"
  count                 = var.existing_vpc_cbr_zone_id != null ? 1 : 0
  use_existing_cbr_zone = true
  existing_zone_id      = var.existing_vpc_cbr_zone_id
  addresses = [
    for network in module.vpc :
    { "type" = "vpc",
    value = network.vpc_crn }
  ]
}
