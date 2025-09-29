variable "ibmcloud_api_key" {
  description = "The API key that's associated with the account to provision resources to."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region of the landing zone VPC."
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "The prefix to add to the VSI, block storage, security group, floating IP, and load balancer resources. Must begin with a lowercase letter and end with a lowercase letter or number. Must be 16 or fewer characters."
  type        = string
  default     = "slz-vsi"
}

variable "vpc_id" {
  description = "The ID of the VPC where you want to deploy the VSI. [Learn more](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ext-with-vsi)."
  type        = string
}

variable "existing_ssh_key_name" {
  description = "The name of a public SSH key in the region where you want to deploy the VSI. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). To create an SSH key, use the 'ssh_public_key' input instead."
  type        = string
  default     = null
}


variable "ssh_public_key" {
  description = "A public SSH key that does not exist in the region where you want to deploy the VSI. The key must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). To use an existing key, specify a value in the `existing_ssh_key_name` input instead."
  type        = string
  default     = null

  validation {
    error_message = "The public SSH key must be a valid SSH RSA public key."
    condition     = var.ssh_public_key == null || can(regex("ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3} ?([^@]+@[^@]+)?", var.ssh_public_key))
  }

  validation {
    condition     = var.ssh_public_key != null || var.existing_ssh_key_name != null
    error_message = "Invalid input: both ssh_public_key and existing_ssh_key_name variables cannot be null together. Please provide a value for at least one of them."
  }
}

variable "resource_tags" {
  description = "A list of resource tags to apply to resources created by this solution."
  type        = list(string)
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "A list of access tags to apply to the VSI resources created by this solution."
  default     = []
}

variable "image_name" {
  description = "The image ID used for the VSI. You can run the `ibmcloud is images` CLI command to find available images. The IDs are different in each region."
  type        = string
  default     = "ibm-ubuntu-24-04-3-minimal-amd64-2"
}

variable "vsi_instance_profile" {
  description = "The VSI image profile. You can run the `ibmcloud is instance-profiles` CLI command to see available image profiles."
  type        = string
  default     = "cx2-4x8"
}

variable "user_data" {
  description = "The user data to transfer to the instance. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-user-data)."
  type        = string
  default     = null
}

variable "boot_volume_encryption_key" {
  description = "The CRN of the boot volume encryption key. [Learn more](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ext-with-vsi)."
  type        = string
}

variable "vsi_per_subnet" {
  description = "The number of virtual servers to create on each VSI subnet."
  type        = number
  default     = 1
}

variable "subnet_names" {
  description = "A list of subnet names where you want to deploy a VSI. If not specified, the VSI is deployed to all the `<prefix>-vsi-zone-*` subnets in the VPC. [Learn more](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ext-with-vsi)."
  type        = list(string)
  default     = null

  validation {
    error_message = "subnet_names cannot be an empty list."
    condition     = var.subnet_names == null ? true : length(var.subnet_names) > 0 ? true : false
  }
}

variable "security_group_ids" {
  description = "The IDs of additional security groups to add to the VSI primary network interface (5 or fewer). [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-using-security-groups)."
  type        = list(string)
  default     = []
}

variable "block_storage_volumes" {
  description = "The list of block storage volumes to attach to each VSI. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-creating-block-storage&interface=ui#create-from-vsi)."
  type = list(
    object({
      name              = string
      profile           = string
      capacity          = optional(number)
      iops              = optional(number)
      encryption_key    = optional(string)
      resource_group_id = optional(string)
    })
  )
  default = []
}

variable "skip_iam_authorization_policy" {
  description = "Set to true to skip the creation of an IAM authorization policy that permits all Storage Blocks to read the encryption key from the KMS instance. If set to false, pass in a value for the KMS instance in the existing_kms_instance_guid variable. In addition, no policy is created if var.kms_encryption_enabled is set to false."
  type        = bool
  default     = false
}

variable "enable_floating_ip" {
  description = "Whether to create a floating IP for each virtual server."
  type        = bool
  default     = false
}

variable "placement_group_id" {
  description = "Unique ID of the Placement Group for restricting the placement of the instance. If not specified (the default), the VSI are placed on any host. [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-about-placement-groups-for-vpc)."
  type        = string
  default     = null
}

variable "load_balancers" {
  description = "Load balancers to add to VSI"
  type = list(
    object({
      name                       = string
      type                       = string
      listener_port              = optional(number)
      listener_port_max          = optional(number)
      listener_port_min          = optional(number)
      listener_protocol          = string
      connection_limit           = optional(number)
      idle_connection_timeout    = optional(number)
      algorithm                  = string
      protocol                   = string
      health_delay               = number
      health_retries             = number
      health_timeout             = number
      health_type                = string
      pool_member_port           = string
      profile                    = optional(string)
      accept_proxy_protocol      = optional(bool)
      subnet_id_to_provision_nlb = optional(string) # Required for Network Load Balancer. If no value is provided, the first one from the VPC subnet list will be selected.
      dns = optional(
        object({
          instance_crn = string
          zone_id      = string
        })
      )
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

variable "primary_vni_additional_ip_count" {
  description = "The number of secondary reversed IPs to attach to a Virtual Network Interface (VNI). Additional IPs are created only if `manage_reserved_ips` is set to true."
  type        = number
  nullable    = false
  default     = 0
}

variable "use_legacy_network_interface" {
  description = "Set this to true to use legacy network interface for the created instances."
  type        = bool
  default     = false
}

variable "allow_ip_spoofing" {
  description = "Allow IP spoofing on the primary network interface"
  type        = bool
  default     = false
}
