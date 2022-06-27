##############################################################################
# Address Prefixes
##############################################################################

module "prefix_map" {
  source         = "./config_modules/list_to_map"
  key_name_field = "zone_name"
  list = [
    for zone in ["zone-1", "zone-2", "zone-3"] :
    {
      zone_name = zone
      addresses = [
        for address in(lookup(var.address_prefixes, zone, null) == null ? [] : var.address_prefixes[zone]) :
        {
          name = "${var.prefix}-${zone}-${index(var.address_prefixes[zone], address) + 1}"
          cidr = address
          zone = "${var.region}-${index(keys(var.address_prefixes), zone) + 1}"
        }
      ]
    }
  ]
}

module "address_prefixes" {
  source = "./config_modules/list_to_map"
  list = flatten([
    for zone in ["zone-1", "zone-2", "zone-3"] :
    module.prefix_map.value[zone].addresses
  ])
}

##############################################################################
