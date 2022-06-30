##############################################################################
# Create map of COS instance to be retrieved from data
##############################################################################

module "cos_data_map" {
  source             = "../list_to_map"
  list               = var.cos
  lookup_field       = "use_data"
  lookup_value_regex = "^true$"
}

##############################################################################

##############################################################################
# Create map of COS instance to create
##############################################################################

module "cos_map" {
  source             = "../list_to_map"
  list               = var.cos
  lookup_field       = "use_data"
  lookup_value_regex = "false|null"
}

##############################################################################

##############################################################################
# Convert COS Resource Key List to Map
##############################################################################

module "cos_key_map" {
  source        = "../nested_list_to_map_and_merge"
  list          = var.cos
  sub_list_name = "keys"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "instance"
    },
    {
      parent_field = "random_suffix"
      child_key    = "random_suffix"
    }
  ]
  add_lookup_child_values = [
    {
      lookup_field_key_name = "parameters"
      lookup_field          = "enable_HMAC"
      parse_json_if_true    = "{\"HMAC\" : true}"
    }
  ]
}

##############################################################################

##############################################################################
# COS Bucket Map
##############################################################################

module "cos_bucket_map" {
  source        = "../nested_list_to_map_and_merge"
  list          = var.cos
  sub_list_name = "buckets"
  add_parent_fields_to_child = [
    {
      parent_field = "name"
      child_key    = "instance"
    },
    {
      parent_field = "use_data"
      child_key    = "use_data"
    },
    {
      parent_field = "random_suffix"
      child_key    = "random_suffix"
    }
  ]
}

##############################################################################

##############################################################################
# COS Data Source ID Map
##############################################################################

module "cos_data_source_id_map" {
  source         = "../list_to_map_value"
  list           = var.cos_data_source
  value_key_name = "id"
}

##############################################################################

##############################################################################
# COS Resource Instance ID Map
##############################################################################

module "cos_resource_id_map" {
  source         = "../list_to_map_value"
  list           = var.cos_resource
  value_key_name = "id"
  key_replace_value = {
    find    = var.suffix == "" ? "${var.prefix}-" : "/${var.prefix}-|-${var.suffix}/"
    replace = ""
  }
}

##############################################################################

##############################################################################
# COS Bucket to Instance Map
##############################################################################

module "cos_bucket_to_instance_map" {
  source         = "../list_to_map"
  key_name_field = "bucket_name"
  list = flatten([
    # For each instance
    for instance in var.cos :
    [
      # For each bucket
      for bucket in instance.buckets :
      {
        id          = local.cos_instance_ids[instance.name] # ID is name of the instance where bucket resides
        name        = instance.name                         # Name is instance name
        bucket_name = bucket.name                           # Used as key for map
        bind_key = (                                        # Get cos bind key data
          # Null if null keys
          lookup(instance, "keys", null) == null
          ? null
          # Null if empty list
          : length(instance.keys) == 0
          ? null
          # Otherwise get credential
          : var.cos_resource_keys[instance.keys[0].name].credentials.apikey
        )
      }
    ]
  ])
}

locals {
  cos_instance_ids = merge(module.cos_data_source_id_map.value, module.cos_resource_id_map.value)
}

##############################################################################

##############################################################################
# COS Outputs
##############################################################################

output "cos_instance_ids" {
  description = "Map of cos ids"
  value       = local.cos_instance_ids
}

output "cos_data_map" {
  description = "Map of COS data resources"
  value       = module.cos_data_map.value
}

output "cos_map" {
  description = "Map of COS resources"
  value       = module.cos_map.value
}

output "cos_bucket_map" {
  description = "Map including key of bucket names with bucket data as values"
  value       = module.cos_bucket_map.value
}

output "cos_key_map" {
  description = "Map of COS keys"
  value       = module.cos_key_map.value
}

output "bucket_to_instance_map" {
  description = "Maps bucket names to instance ids and api keys"
  value       = module.cos_bucket_to_instance_map.value
}

##############################################################################
