##############################################################################
# Create new resource groups and reference existing groups
##############################################################################

data "ibm_resource_group" "resource_groups" {
  for_each = {
    for group in var.resource_groups :
    (group.name) => group if group.create != true
  }
  name = each.value.use_prefix == true ? "${var.prefix}-${each.key}" : each.key
}

resource "ibm_resource_group" "resource_groups" {
  for_each = {
    for group in var.resource_groups :
    (group.name) => group if group.create == true
  }
  name = each.value.use_prefix == true ? "${var.prefix}-${each.key}" : each.key
  tags = var.tags
}

##############################################################################


##############################################################################
# Create a local map with resource group names as keys and ids as values
# Functionally the same as cos function to do the same
##############################################################################

locals {
  resource_groups_info = merge(
    {
      for group in data.ibm_resource_group.resource_groups :
      group.name => group.id
    },
    {
      for group in ibm_resource_group.resource_groups :
      group.name => group.id
    }
  )

  # if use_prefix is true, strip off the prefix
  resource_groups = {
    for group in var.resource_groups :
    group.name => local.resource_groups_info[group.use_prefix == true ? "${var.prefix}-${group.name}" : group.name]
  }
}

##############################################################################
