##############################################################################
# Get existing SSH Keys
##############################################################################


data "ibm_is_ssh_keys" "existing_keys" {}


locals {
  # compare the remote keys with input variable, use replace to ensure correct Base64 key is present ensuring padding using `==` symbol at last
  existing_ssh_keys = flatten([
    for data_ssh_key in data.ibm_is_ssh_keys.existing_keys.keys : [
      for ssh_key in var.ssh_keys : {
        id   = data_ssh_key.id
        name = ssh_key.name
      } if data_ssh_key.public_key == replace(ssh_key.public_key == null ? "" : ssh_key.public_key, "/==.*$/", "==")
    ]
  ])
}


##############################################################################
# Create New SSH Key
##############################################################################

resource "ibm_is_ssh_key" "ssh_key" {
  for_each = {
    for ssh_key in var.ssh_keys :
    (ssh_key.name) => ssh_key if ssh_key.public_key != null && var.use_existing_sshkey == false # Create resource only when existing ssh key is not already present.
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