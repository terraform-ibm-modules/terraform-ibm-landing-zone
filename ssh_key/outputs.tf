##############################################################################
# All SSH Keys
##############################################################################

output "ssh_keys" {
  description = "List of SSH keys from this module."
  value = flatten([
    [
      for create_ssh_key in {
        for ssh_key in var.ssh_keys :
        (ssh_key.name) => ssh_key if ssh_key.public_key != null && local.key_already_exists == false
      } :
      {
        name   = create_ssh_key.name
        id     = ibm_is_ssh_key.ssh_key[create_ssh_key.name].id
        create = create_ssh_key.create
      }

    ],
    [
      for data_ssh_key in {
        for ssh_key in local.existing_ssh_keys :
        (ssh_key.name) => ssh_key if local.key_already_exists == true
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
          (ssh_key.name) => ssh_key if ssh_key.public_key != null && local.key_already_exists == false
        } :
        {
          name   = create_ssh_key.name
          id     = ibm_is_ssh_key.ssh_key[create_ssh_key.name].id
          create = create_ssh_key.create
        }
      ],
      [
        for create_ssh_key in {
          for ssh_key in var.ssh_keys :
          (ssh_key.name) => ssh_key if ssh_key.create == false
        } :
        {
          name   = create_ssh_key.name
          id     = create_ssh_key.id
          create = create_ssh_key.create
        }

      ],
      [
        for data_ssh_key in {
          for ssh_key in local.existing_ssh_keys :
          (ssh_key.name) => ssh_key if local.key_already_exists == true
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
