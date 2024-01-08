##############################################################################
# Account Variables
##############################################################################

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
}

##############################################################################


##############################################################################
# KMS Variables
##############################################################################

variable "key_management" {
  description = "Object describing the Key Protect instance"
  type = object({
    name              = string
    use_hs_crypto     = optional(bool) # can be hpcs or keyprotect
    use_data          = optional(bool)
    resource_group_id = optional(string)
    tags              = list(string)
    access_tags       = optional(list(string), [])
  })
}

variable "keys" {
  description = "List of keys to be created for the service"
  type = list(
    object({
      name             = string
      root_key         = optional(bool)
      payload          = optional(string)
      key_ring         = optional(string) # Any key_ring added will be created
      force_delete     = optional(bool)
      existing_key_crn = optional(string)
      endpoint         = optional(string) # can be public or private
      iv_value         = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      encrypted_nonce  = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      policies = optional(
        object({
          rotation = optional(
            object({
              interval_month = number
            })
          )
          dual_auth_delete = optional(
            object({
              enabled = bool
            })
          )
        })
      )
    })
  )

  validation {
    error_message = "Each key must have a unique name."
    condition     = length(distinct(var.keys[*].name)) == length(var.keys[*].name)
  }

  validation {
    error_message = "Key endpoints can only be `public` or `private`."
    condition = length([
      for kms_key in var.keys :
      true if kms_key.endpoint != null && kms_key.endpoint != "public" && kms_key.endpoint != "private"
    ]) == 0
  }

  validation {
    error_message = "Rotation interval month can only be from 1 to 12."
    condition = length([
      for kms_key in [
        for rotation_key in [
          for policy_key in var.keys :
          policy_key if policy_key.policies != null
        ] :
        rotation_key if rotation_key.policies.rotation != null
      ] : true if kms_key.policies.rotation.interval_month < 1 || kms_key.policies.rotation.interval_month > 12
    ]) == 0
  }
}

variable "service_endpoints" {
  description = "Service endpoints. Can be `public`, `private`, or `public-and-private`"
  type        = string
  default     = "public-and-private"

  validation {
    error_message = "Service endpoints can only be `public`, `private`, or `public-and-private`."
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
  }
}
##############################################################################
