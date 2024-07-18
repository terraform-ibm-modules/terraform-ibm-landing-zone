##############################################################################
# Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters. Prefixes must end with a letter or number and be 16 or fewer characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "vpc_list" {
  description = "List of VPCs"
  type        = list(string)
}

variable "bastion_resource_list" {
  description = "List of Bastion resources. Can be `[\"bastion\"]` or `[]`."
  type        = list(string)

  validation {
    error_message = "Bastion resource length must be 1 or 0."
    condition     = length(var.bastion_resource_list) == 0 || length(var.bastion_resource_list) == 1
  }

  validation {
    error_message = "Bastion resource can only have the value `bastion`."
    condition     = length(var.bastion_resource_list) == 0 ? true : var.bastion_resource_list[0] == "bastion"
  }
}


variable "use_random_cos_suffix" {
  description = "Add a random 8 character string to the end of each cos instance, bucket, and key."
  type        = bool
  default     = false
}

variable "existing_cos_instance_name" {
  description = "Specify the name of an existing Cloud Object Storage (COS) instance that can be used for new buckets, if required."
  type        = string
  default     = null
}

variable "existing_cos_resource_group" {
  description = "For using an existing Cloud Object Storage (COS) instance, specify the name of the resource group for the instance in `existing_cos_instance_name`. Leave as null for the `Default` resource group or if not using an existing COS."
  type        = string
  default     = null
}

variable "endpoint_type" {
  description = "Endpoint type to use when creating buckets"
  type        = string
  default     = "public"
}

variable "use_existing_cos_for_vpc_flowlogs" {
  description = "Set to `true` if you have chosen to include an `existing_cos_instance_name` and wish to use that instance for your VPC Flow Log bucket. This setting will only be used if an `existing_cos_instance_name` is supplied."
  type        = bool
  default     = false
}

variable "use_existing_cos_for_atracker" {
  description = "Set to `true` if you have chosen to include an `existing_cos_instance_name` and wish to use that instance for your Activity Tracker (atracker) routing. This setting will only be used if an `existing_cos_instance_name` is supplied."
  type        = bool
  default     = false
}

##############################################################################

locals {
  flow_log_buckets = [
    # Create one flow log bucket for each VPC network
    for network in concat(var.vpc_list, var.bastion_resource_list) :
    {
      name          = "${network}-bucket"
      storage_class = "standard"
      kms_key       = "${var.prefix}-slz-key"
      endpoint_type = var.endpoint_type
      force_delete  = true
    }
  ]

  atracker_buckets = [
    {
      name          = "atracker-bucket"
      storage_class = "standard"
      endpoint_type = var.endpoint_type
      kms_key       = "${var.prefix}-atracker-key"
      force_delete  = true
    }
  ]

  bastion_keys = [
    # Create Bastion COS key
    for key_name in var.bastion_resource_list :
    {
      name        = "${key_name}-key"
      enable_HMAC = true
      role        = "Writer"
    }
  ]

  atracker_cos = !var.use_existing_cos_for_atracker ? [
    # Activity Tracker COS instance, existing COS or new, plus bucket for atracker
    {
      name           = "atracker-cos"
      use_data       = false
      resource_group = "${var.prefix}-service-rg"
      plan           = "standard"
      buckets        = local.atracker_buckets
      keys           = []
      access_tags    = []
      random_suffix  = var.use_random_cos_suffix
    }
  ] : []

  # LZ COS
  main_cos = [
    {
      name           = "cos"
      use_data       = false
      resource_group = "${var.prefix}-service-rg"
      plan           = "standard"
      buckets        = var.use_existing_cos_for_vpc_flowlogs ? [] : local.flow_log_buckets
      keys = [
        # Create Bastion COS key
        for key_name in var.bastion_resource_list :
        {
          name        = "${key_name}-key"
          enable_HMAC = true
          role        = "Writer"
        }
      ]
      access_tags   = []
      random_suffix = var.use_random_cos_suffix
    }
  ]

  # if existing COS is to be used, include that, if not leave empty
  existing_cos = var.existing_cos_instance_name != null ? [
    {
      name           = var.existing_cos_instance_name
      use_data       = true
      resource_group = var.existing_cos_resource_group
      plan           = "standard"
      buckets = concat(
        (var.use_existing_cos_for_vpc_flowlogs ? local.flow_log_buckets : []),
        (var.use_existing_cos_for_atracker ? local.atracker_buckets : [])
      )
      keys          = []
      access_tags   = []
      random_suffix = var.use_random_cos_suffix
    }
  ] : []
}

##############################################################################
# Output
##############################################################################

output "value" {
  description = "A list of cloud object storage instances, keys, and buckets to create."
  value       = concat(local.atracker_cos, local.main_cos, local.existing_cos)
}

##############################################################################
