##############################################################################
# SSH Key List
##############################################################################

locals {
  ssh_keys = [
    for ssh_key in var.ssh_keys :
    merge(
      {
        resource_group_id : (
          lookup(ssh_key, "resource_group", null) == null
          ? null
          : var.resource_groups[ssh_key.resource_group]
        )
      },
      ssh_key
    )
  ]
}

##############################################################################

##############################################################################
# Output List
##############################################################################

output "ssh_key_list" {
  description = "List of SSH keys with resource group added"
  value       = local.ssh_keys
}

##############################################################################