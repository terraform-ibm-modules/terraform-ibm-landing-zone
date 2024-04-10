##############################################################################
# SSH Key Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources that is prepended to resources that are provisioned. Must begin with a lowercase letter and end with a lowercase letter or number. Must be 16 or fewer characters."
  type        = string
  default     = "gcat-multizone-schematics"

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "tags" {
  description = "A list of resource tags to be added to resources"
  type        = list(string)
  default     = []
}

variable "ssh_keys" {
  description = "SSH keys to use to provision a VSI. If `public_key` is not provided, the named key will be looked up from data. See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys."
  type = list(
    object({
      name              = string
      public_key        = optional(string)
      resource_group_id = optional(string)
    })
  )
  default = [
    {
      name       = "dev-ssh-key"
      public_key = "<ssh public key>"
    }
  ]

  validation {
    error_message = "Each SSH key must have a unique name."
    condition     = length(distinct(var.ssh_keys[*].name)) == length(var.ssh_keys[*].name)
  }

  validation {
    error_message = "Each key using the public_key field must have a unique public key."
    condition = length(
      distinct(
        [
          for ssh_key in var.ssh_keys :
          ssh_key.public_key if ssh_key.public_key != null
        ]
      )
      ) == length(
      [
        for ssh_key in var.ssh_keys :
        ssh_key.public_key if ssh_key.public_key != null
      ]
    )
  }
}

##############################################################################
