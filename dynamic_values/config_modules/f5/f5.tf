##############################################################################
# Map of F5 Values to get subnets
##############################################################################

module "f5_vsi_map" {
  source = "../list_to_map"
  list   = var.f5_vsi
}

##############################################################################

##############################################################################
# F5 Primary interface subnets
##############################################################################

module "f5_primary_subnets" {
  source           = "../get_subnets"
  for_each         = module.f5_vsi_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = each.value.primary_subnet_name
}

##############################################################################

##############################################################################
# F5 Secondary interface subnets
##############################################################################

module "f5_secondary_subnets" {
  source           = "../get_subnets"
  for_each         = module.f5_vsi_map.value
  subnet_zone_list = var.vpc_modules[each.value.vpc_name].subnet_zone_list
  regex            = join("|", each.value.secondary_subnet_names)
}

##############################################################################

##############################################################################
# F5 Map with vpc ID and subnets
##############################################################################

module "composed_f5_map" {
  source = "../list_to_map"
  list = [
    for group in var.f5_vsi :
    merge(group, {
      vpc_id            = var.vpc_modules[group.vpc_name].vpc_id
      subnets           = module.f5_primary_subnets[group.name].subnets
      secondary_subnets = module.f5_secondary_subnets[group.name].subnets
      zone              = module.f5_primary_subnets[group.name].subnets[0].zone
    })
  ]
  prefix = var.prefix
}

##############################################################################

##############################################################################
# F5 Cloud Init Data
##############################################################################

module "f5_cloud_init" {
  for_each                = module.composed_f5_map.value
  source                  = "../../../f5_config"
  vpc_id                  = each.value.vpc_id
  zone                    = each.value.zone
  secondary_subnets       = each.value.secondary_subnets
  hostname                = each.value.hostname
  domain                  = each.value.domain
  tmos_admin_password     = lookup(var.f5_template_data, "tmos_admin_password", null) == null ? "null" : lookup(var.f5_template_data, "tmos_admin_password", null)
  license_type            = lookup(var.f5_template_data, "license_type", null) == null ? "null" : lookup(var.f5_template_data, "license_type", null)
  byol_license_basekey    = lookup(var.f5_template_data, "byol_license_basekey", null) == null ? "null" : lookup(var.f5_template_data, "byol_license_basekey", null)
  license_host            = lookup(var.f5_template_data, "license_host", null) == null ? "null" : lookup(var.f5_template_data, "license_host", null)
  license_username        = lookup(var.f5_template_data, "license_username", null) == null ? "null" : lookup(var.f5_template_data, "license_username", null)
  license_password        = lookup(var.f5_template_data, "license_password", null) == null ? "null" : lookup(var.f5_template_data, "license_password", null)
  license_pool            = lookup(var.f5_template_data, "license_pool", null) == null ? "null" : lookup(var.f5_template_data, "license_pool", null)
  license_sku_keyword_1   = lookup(var.f5_template_data, "license_sku_keyword_1", null) == null ? "null" : lookup(var.f5_template_data, "license_sku_keyword_1", null)
  license_sku_keyword_2   = lookup(var.f5_template_data, "license_sku_keyword_2", null) == null ? "null" : lookup(var.f5_template_data, "license_sku_keyword_2", null)
  license_unit_of_measure = lookup(var.f5_template_data, "license_unit_of_measure", null) == null ? "null" : lookup(var.f5_template_data, "license_unit_of_measure", null)
  do_declaration_url      = lookup(var.f5_template_data, "do_declaration_url", null) == null ? "null" : lookup(var.f5_template_data, "do_declaration_url", null)
  as3_declaration_url     = lookup(var.f5_template_data, "as3_declaration_url", null) == null ? "null" : lookup(var.f5_template_data, "as3_declaration_url", null)
  ts_declaration_url      = lookup(var.f5_template_data, "ts_declaration_url", null) == null ? "null" : lookup(var.f5_template_data, "ts_declaration_url", null)
  phone_home_url          = lookup(var.f5_template_data, "phone_home_url", null) == null ? "null" : lookup(var.f5_template_data, "phone_home_url", null)
  template_source         = lookup(var.f5_template_data, "template_source", null) == null ? "null" : lookup(var.f5_template_data, "template_source", null)
  template_version        = lookup(var.f5_template_data, "template_version", null) == null ? "null" : lookup(var.f5_template_data, "template_version", null)
  app_id                  = lookup(var.f5_template_data, "app_id", null) == null ? "null" : lookup(var.f5_template_data, "app_id", null)
  tgactive_url            = lookup(var.f5_template_data, "tgactive_url", null) == null ? "null" : lookup(var.f5_template_data, "tgactive_url", null)
  tgstandby_url           = lookup(var.f5_template_data, "tgstandby_url", null) == null ? "null" : lookup(var.f5_template_data, "tgstandby_url", null)
  tgrefresh_url           = lookup(var.f5_template_data, "tgrefresh_url", null) == null ? "null" : lookup(var.f5_template_data, "tgrefresh_url", null)
}


##############################################################################

##############################################################################
# F5 Outputs
##############################################################################

output "f5_vsi_map" {
  description = "Map of VSI deployments"
  value       = module.composed_f5_map.value
}

output "f5_template_map" {
  description = "Map of template data for f5 deployments"
  value       = module.f5_cloud_init
}

##############################################################################
