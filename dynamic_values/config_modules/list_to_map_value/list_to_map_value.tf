##############################################################################
# Variables
##############################################################################

variable "list" {
  description = "List of objects"
}

variable "prefix" {
  description = "Prefix to add to map keys"
  type        = string
  default     = ""
}

variable "key_name_field" {
  description = "Key inside each object to use as the map key"
  type        = string
  default     = "name"
}

variable "value_key_name" {
  description = "Key of the value to set as the key name value"
  type        = string
}

variable "key_replace_value" {
  description = "Replace a string inside the key name"
  type = object({
    find    = string
    replace = string
  })
  default = {
    find    = ""
    replace = ""
  }
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "List converted into map"
  value = {
    for item in var.list :
    (
      "${
        # If prefix is empty, add empty, otherwise add prefix and dash
        var.prefix == "" ? "" : "${var.prefix}-"
        }${
        # Replace found string with replace string for key
        replace(item[var.key_name_field], var.key_replace_value.find, var.key_replace_value.replace)
    }") => item[var.value_key_name]
  }
}

##############################################################################
