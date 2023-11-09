variable "ibmcloud_api_key" {
  description = "The API key that's associated with the account to provision resources to"
  type        = string
  sensitive   = true
}

variable "resource_group" {
  type        = string
  description = "The resource group name of the landing zone VPC."
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

variable "vpc_id" {
  description = "The ID of the VPC where the VSI will be created."
  type        = string
  default     = null
}

variable "existing_ssh_key_name" {
  description = "The ID of the VPC where the VSI will be created."
  type        = string
  default     = null
}


variable "ssh_public_key" {
  description = "SSH keys to use to provision a VSI. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). If `public_key` is not provided, the named key will be looked up from data. See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys."
  type        = string

  validation {
    error_message = "The public SSH key must be a valid SSH RSA public key."
    condition     = var.ssh_public_key == null || can(regex("ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3} ?([^@]+@[^@]+)?", var.ssh_public_key))
  }
}

variable "resource_tags" {
  description = "A list of tags to add to the VSI, block storage, security group, floating IP, and load balancer created by the module."
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
  default     = "ibm-ubuntu-22-04-2-minimal-amd64-1"
}

variable "machine_type" {
  description = "VSI machine type"
  type        = string
  default     = "cx2-2x4"
}

variable "user_data" {
  description = "User data to initialize VSI deployment."
  type        = string
  default     = null
}

variable "boot_volume_encryption_key" {
  description = "The CRN of the boot volume encryption key."
  type        = string
}

variable "existing_kms_instance_guid" {
  description = "The GUID of the KMS instance that holds the key specified in `var.boot_volume_encryption_key`."
  type        = string
}

variable "skip_iam_authorization_policy" {
  type        = bool
  description = "Set to `true` to skip the creation of an IAM authorization policy that permits all storage blocks to read the encryption key from the KMS instance. If set to `false` (and creating a policy), specify the GUID of the KMS instance in the `existing_kms_instance_guid` variable."
  default     = false
}

variable "vsi_per_subnet" {
  description = "The number of VSI instances for each subnet."
  type        = number
  default     = 1
}

variable "subnet_names" {
  description = "The subnets to deploy the VSI instances to."
  type        = list(string)
  default = [
    "vpe-zone-1",
    "vpe-zone-2",
    "vpe-zone-3"
  ]
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
      name              = string
      type              = string
      listener_port     = number
      listener_protocol = string
      connection_limit  = number
      algorithm         = string
      protocol          = string
      health_delay      = number
      health_retries    = number
      health_timeout    = number
      health_type       = string
      pool_member_port  = string
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

variable "prerequisite_workspace_id" {
  type        = string
  description = "IBM Cloud Schematics workspace ID of the prerequisite IBM VPC landing zone. If you do not have an existing deployment yet, create a new architecture using the same catalog tile."
  default     = null
}

variable "existing_vpc_name" {
  type        = string
  description = "Name of the VPC to be used for deploying the VSI from the list of VPCs retrived from the IBM Cloud Schematics workspace."
  default     = null
}
