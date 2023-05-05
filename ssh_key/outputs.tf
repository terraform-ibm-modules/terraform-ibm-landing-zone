##############################################################################
# All SSH Keys
##############################################################################

output "ssh_keys" {
  description = "List of SSH keys from this module."
  value = flatten([
    [
      for create_ssh_key in {
        for ssh_key in var.ssh_keys :
        (ssh_key.name) => ssh_key if ssh_key.public_key != null && var.use_existing_sshkey == false # Create a ssh key if not already found
      } :
      {
        name = create_ssh_key.name
        id   = ibm_is_ssh_key.ssh_key[create_ssh_key.name].id
      }

    ],
    [
      for data_ssh_key in {
        for ssh_key in local.existing_ssh_keys :
        (ssh_key.name) => ssh_key if var.use_existing_sshkey == true # Do not create a ssh key if already present
      } :
      {
        name = data_ssh_key.name
        id   = data_ssh_key.id
      }
    ],
    [
      for data_ssh_key in {
        for ssh_key in var.ssh_keys :
        (ssh_key.name) => ssh_key if ssh_key.public_key == null
      } :
      {
        name = data_ssh_key.name
        id   = data.ibm_is_ssh_key.ssh_key[data_ssh_key.name].id
      }
    ]
  ])
}

output "ssh_key_map" {
  description = "map of ssh keys"
  value = {
    for key in flatten([
      [
        for create_ssh_key in {
          for ssh_key in var.ssh_keys :
          (ssh_key.name) => ssh_key if ssh_key.public_key != null && var.use_existing_sshkey == false 
        } :
        {
          name = create_ssh_key.name
          id   = ibm_is_ssh_key.ssh_key[create_ssh_key.name].id
        }
      ],
      [
        for data_ssh_key in {
          for ssh_key in local.existing_ssh_keys :
          (ssh_key.name) => ssh_key if var.use_existing_sshkey == true
        } :
        {
          name = data_ssh_key.name
          id   = data_ssh_key.id
        }
      ],
      [
        for data_ssh_key in {
          for ssh_key in var.ssh_keys :
          (ssh_key.name) => ssh_key if ssh_key.public_key == null
        } :
        {
          name = data_ssh_key.name
          id   = data.ibm_is_ssh_key.ssh_key[data_ssh_key.name].id
        }
      ]
    ]) : (key.name) => key
  }
}

##############################################################################