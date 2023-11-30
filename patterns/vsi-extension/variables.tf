variable "ibmcloud_api_key" {
  description = "The API key that's associated with the account to provision resources to"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region of the landing zone VPC."
  type        = string
}

variable "prefix" {
  description = "The prefix to add to the VSI, block storage, security group, floating IP, and load balancer resources."
  type        = string
  default     = "slz-vsi"
}

// TODO: Update the vpc_id description
variable "vpc_id" {
  description = "The ID of the VPC where the VSI will be created."
  type        = string
}

variable "existing_ssh_key_name" {
  description = "The name of a public SSH Key which already exists in the deployment region that will be used for VSI creation. To add a new SSH key, use the variable 'ssh_public_key' instead."
  type        = string
  default     = null
}


variable "ssh_public_key" {
  description = "A public SSH Key for VSI creation which does not already exist in the deployment region. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended) - See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys. To use an existing key, enter a value for the variable 'existing_ssh_key_name' instead."
  type        = string

  validation {
    error_message = "The public SSH key must be a valid SSH RSA public key."
    condition     = var.ssh_public_key == null || can(regex("ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3} ?([^@]+@[^@]+)?", var.ssh_public_key))
  }
}

variable "resource_tags" {
  description = "List of resource tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by the module."
  default     = []
}

variable "image_name" {
  description = "Image ID used for the VSI. Run the 'ibmcloud is images' CLI command to find available images. The IDs are different in each region."
  type        = string
  default     = "ibm-ubuntu-22-04-3-minimal-amd64-1"
}

variable "vsi_instance_profile" {
  description = "VSI image profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles"
  type        = string
  default     = "cx2-4x8"
}

variable "user_data" {
  description = "User data to transfer to the instance. For more information, see https://cloud.ibm.com/docs/vpc?topic=vpc-user-data."
  type        = string
  default     = null
}

// TODO: Update the boot_volume_encryption_key description
variable "boot_volume_encryption_key" {
  description = "The CRN of the boot volume encryption key."
  type        = string
}

variable "vsi_per_subnet" {
  description = "Number of Virtual Servers to create on each VSI subnet."
  type        = number
  default     = 1
}

// TODO: Update the subnet_names description
variable "subnet_names" {
  description = "The subnets to deploy the VSI instances to. Defaults to null to deploy VSI to all the subnets in the VPC."
  type        = list(string)
  default     = null

  validation {
    error_message = "subnet_names cannot be an empty list."
    condition     = var.subnet_names == null ? true : length(var.subnet_names) > 0 ? true : false
  }
}

variable "security_group_ids" {
  description = "IDs of additional security groups to add to the VSI deployment primary interface. A VSI interface can have a maximum of 5 security groups."
  type        = list(string)
  default     = []
}

variable "block_storage_volumes" {
  description = "The list of block storage volumes to attach to each VSI."
  type = list(
    object({
      name           = string
      profile        = string
      capacity       = optional(number)
      iops           = optional(number)
      encryption_key = optional(string)
    })
  )
  default = []
}

variable "enable_floating_ip" {
  description = "Set to `true` to create a floating IP for each virtual server."
  type        = bool
  default     = false
}

variable "placement_group_id" {
  description = "Unique Identifier of the Placement Group for restricting the placement of the instance, default behaviour is placement on any host"
  type        = string
  default     = null
}

variable "load_balancers" {
  description = "The load balancers to add to the VSI."
  type = list(
    object({
      name                    = string
      type                    = string
      listener_port           = number
      listener_protocol       = string
      connection_limit        = number
      algorithm               = string
      protocol                = string
      health_delay            = number
      health_retries          = number
      health_timeout          = number
      health_type             = string
      pool_member_port        = string
      idle_connection_timeout = optional(number)
      security_group = optional(
        object({
          name = string
          rules = list(
            object({
              name      = string
              direction = string
              source    = string
              tcp = optional(
                object({
                  port_max = number
                  port_min = number
                })
              )
              udp = optional(
                object({
                  port_max = number
                  port_min = number
                })
              )
              icmp = optional(
                object({
                  type = number
                  code = number
                })
              )
            })
          )
        })
      )
    })
  )
  default = []
}
