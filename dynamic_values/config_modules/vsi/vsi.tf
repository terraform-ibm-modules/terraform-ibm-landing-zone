##############################################################################
# VSI List To Map
##############################################################################

module "vsi_list_to_map" {
  source = "../list_to_map"
  list   = var.vsi
  prefix = var.prefix
}

##############################################################################

##############################################################################
# Get VSI Subnets
##############################################################################

module "vsi_subnets" {
  source           = "../get_subnets"
  for_each         = module.vsi_list_to_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = join("|", each.value.subnet_names)
}

##############################################################################

##############################################################################
# Composed VSI Map
##############################################################################

module "composed_vsi_map" {
  source = "../list_to_map"
  prefix = var.prefix
  list = [
    for vsi_group in var.vsi :
    merge(vsi_group, {
      vpc_id  = var.vpc_modules[vsi_group.vpc_name].vpc_id
      subnets = module.vsi_subnets["${var.prefix}-${vsi_group.name}"].subnets
    })
  ]
}

##############################################################################

##############################################################################
# VSI Images
##############################################################################

module "vsi_image_map" {
  source = "../list_to_map"
  list = [
    for instance in concat(var.vsi, var.bastion_vsi) :
    {
      name       = "${var.prefix}-${instance.name}"
      image_name = instance.image_name
    }
  ]
}

##############################################################################

##############################################################################
# VSI Outputs
##############################################################################

output "vsi_map" {
  description = "Map of VSI deployments"
  value       = module.composed_vsi_map.value
}

output "vsi_image_map" {
  description = "Map of VSI images"
  value       = module.vsi_image_map.value
}

##############################################################################
