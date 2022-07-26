##############################################################################
# Create New SSH Key
##############################################################################

resource "ibm_is_ssh_key" "ssh_key" {
  for_each = {
    for ssh_key in var.ssh_keys :
    (ssh_key.name) => ssh_key if ssh_key.public_key != null
  }
  name           = "${var.prefix}-${each.value.name}"
  public_key     = replace(each.value.public_key, "/==.*$/", "==")
  resource_group = each.value.resource_group_id
  tags           = var.tags
}

##############################################################################


##############################################################################
# Get SSH Key From Data
##############################################################################

data "ibm_is_ssh_key" "ssh_key" {
  for_each = {
    for ssh_key in var.ssh_keys :
    (ssh_key.name) => ssh_key if ssh_key.public_key == null
  }
  name = each.value.name
}

##############################################################################
