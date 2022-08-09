##############################################################################
# Variables
##############################################################################

variable "list" {
  description = "List to get sub list from"
}

variable "sub_list_name" {
  description = "Name of key for nested list inside list object"
  type        = string
}

variable "add_parent_fields_to_child" {
  description = "List of values to add to the child element on return"
  type = list(
    object({
      parent_field = string
      child_key    = string
      add_prefix   = optional(string)
    })
  )
}

variable "add_lookup_child_values" {
  description = "List of values to check for a child value"
  type = list(
    object({
      lookup_field_key_name = string
      lookup_field          = string
      parse_json_if_true    = string
    })
  )
  default = []
}

variable "key_name_field" {
  description = "Key inside each object to use as the map key"
  type        = string
  default     = "name"
}

variable "prepend_parent_key_value_to_child_name" {
  description = "Add a value from the parent object to the beginning of the key name"
  type        = string
  default     = null
}

##############################################################################

##############################################################################
# Netsted List to Map
##############################################################################

locals {
  use_parent_key = var.prepend_parent_key_value_to_child_name != null ? true : false
}

module "list_to_map" {
  source         = "../list_to_map"
  key_name_field = local.use_parent_key ? "composed_name" : var.key_name_field
  list = flatten([
    # For each parent in the list
    for parent in var.list :
    [
      # Get the children from that list
      for child in parent[var.sub_list_name] :
      merge(child,
        {
          # if use parent key, parent key, otherwise empty string
          composed_name = "${local.use_parent_key ? parent[var.prepend_parent_key_value_to_child_name] : ""}-${child[var.key_name_field]}"
        },
        {
          for value in var.add_lookup_child_values :
          (value.lookup_field_key_name) => lookup(child, value.lookup_field, null) == true ? jsondecode(value.parse_json_if_true) : null
        }
      )
      # If the child key is not null
    ] if lookup(parent, var.sub_list_name, null) != null
  ])
}

##############################################################################

##############################################################################
# List to map for only merge values
##############################################################################

module "parent_merge_list_to_map" {
  source         = "../list_to_map"
  key_name_field = local.use_parent_key ? "composed_name" : var.key_name_field
  list = flatten([
    # For each parent in the list
    for parent in var.list :
    [
      # For each child list in the parent list
      for child in parent[var.sub_list_name] :
      # Merge to create object
      merge({
        # Create a key for the name with the child value
        (var.key_name_field) = child[var.key_name_field]
        composed_name = "${
          # if use parent key, parent key, otherwise empty string
          local.use_parent_key ? parent[var.prepend_parent_key_value_to_child_name] : ""
        }-${child[var.key_name_field]}"
        },
        {
          # For each field to add from parent to child
          for field in var.add_parent_fields_to_child :
          (field.child_key) => (
            field.add_prefix == null ? lookup(parent, field.parent_field, null) : "${field.add_prefix}-${parent[field.parent_field]}"
          )
        }
      )
      # If parent has valid children
    ] if lookup(parent, var.sub_list_name, null) != null
  ])
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "value" {
  description = "Map with merged keys"
  value = {
    for child_key in keys(module.list_to_map.value) :
    child_key => merge(
      module.list_to_map.value[child_key],
      module.parent_merge_list_to_map.value[child_key]
    )
  }
}

##############################################################################
