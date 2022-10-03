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

variable "lookup_field" {
  description = "Name of the field to find with lookup"
  type        = string
  default     = null
}

variable "lookup_value_regex" {
  description = "regular expression for reurned value"
  type        = string
  default     = null
}


##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "List converted into map"
  value = {
    for item in var.list :
    ("${var.prefix == "" ? "" : "${var.prefix}-"}${item[var.key_name_field]}") =>
    item if(
      var.lookup_field == null                                                             # If not looking up
      ? true                                                                               # true
      : can(regex(var.lookup_value_regex, tostring(lookup(item, var.lookup_field, null)))) # Otherwise match regex
    )
  }
}

##############################################################################
