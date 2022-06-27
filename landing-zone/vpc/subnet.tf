##############################################################################
# Multizone subnets
##############################################################################

locals {
  subnet_object = module.dynamic_values.subnet_map
}

##############################################################################


##############################################################################
# Create New Prefixes
##############################################################################

resource "ibm_is_vpc_address_prefix" "subnet_prefix" {
  # Address prefixes replace subnet prefixes
  for_each = length(local.address_prefixes) > 0 ? {} : local.subnet_object
  name     = each.value.prefix_name
  zone     = each.value.zone_name
  vpc      = ibm_is_vpc.vpc.id
  cidr     = each.value.cidr
}

##############################################################################


##############################################################################
# Create Subnets
##############################################################################

resource "ibm_is_subnet" "subnet" {
  for_each        = local.subnet_object
  vpc             = ibm_is_vpc.vpc.id
  name            = each.key
  zone            = each.value.zone_name
  resource_group  = var.resource_group_id
  ipv4_cidr_block = length(keys(local.address_prefixes)) == 0 ? ibm_is_vpc_address_prefix.subnet_prefix[each.value.prefix_name].cidr : each.value.cidr
  network_acl     = ibm_is_network_acl.network_acl[each.value.acl].id
  public_gateway  = each.value.public_gateway
  depends_on      = [ibm_is_vpc_address_prefix.address_prefixes]
}

##############################################################################
