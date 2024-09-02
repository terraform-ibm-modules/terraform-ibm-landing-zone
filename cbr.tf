##############################################################################
# Update existing CBR VPC network zone
##############################################################################

resource "ibm_cbr_zone_addresses" "add_slz_vpc_crns" {
  count   = var.existing_vpc_cbr_zone_id != null ? 1 : 0
  zone_id = var.existing_vpc_cbr_zone_id
  dynamic "addresses" {
    for_each = module.vpc
    content {
      type  = "vpc"
      value = addresses.value.vpc_crn
    }
  }
}
