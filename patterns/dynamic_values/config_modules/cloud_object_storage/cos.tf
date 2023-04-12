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

##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "A list of cloud object storage instances, keys, and buckets to create."
  value = [
    # Activity Tracker COS instance
    {
      name           = "atracker-cos"
      use_data       = false
      resource_group = "${var.prefix}-service-rg"
      plan           = "standard"
      buckets = [
        {
          name          = "atracker-bucket"
          storage_class = "standard"
          endpoint_type = "public"
          kms_key       = "${var.prefix}-atracker-key"
          force_delete  = true
        }
      ]
      keys          = []
      random_suffix = var.use_random_cos_suffix
    },
    # COS instance for everything else
    {
      name           = "cos"
      use_data       = false
      resource_group = "${var.prefix}-service-rg"
      plan           = "standard"
      buckets = [
        # Create one flow log bucket for each VPC network
        for network in concat(var.vpc_list, var.bastion_resource_list) :
        {
          name          = "${network}-bucket"
          storage_class = "standard"
          kms_key       = "${var.prefix}-slz-key"
          endpoint_type = "public"
          force_delete  = true
        }
      ]
      keys = [
        # Create Bastion COS key
        for key_name in var.bastion_resource_list :
        {
          name        = "${key_name}-key"
          enable_HMAC = true
          role        = "Writer"
        }
      ]
      random_suffix = var.use_random_cos_suffix
    }
  ]
}

##############################################################################
