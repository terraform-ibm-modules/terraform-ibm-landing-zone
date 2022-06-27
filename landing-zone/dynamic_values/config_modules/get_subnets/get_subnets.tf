##############################################################################
# Get a list of subnets
##############################################################################

variable "subnet_zone_list" {
  description = "List of subnet zones"
}

variable "regex" {
  description = "String regex to match"
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "subnets" {
  description = "List of VSI subnets"
  value = [
    for subnet in var.subnet_zone_list :
    subnet if can(regex(var.regex, subnet.name))
  ]
}

output "regex" {
  value = var.regex
}

##############################################################################