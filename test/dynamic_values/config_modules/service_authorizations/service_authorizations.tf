##############################################################################
# Variables
##############################################################################

variable "key_management" {
  description = "Direct reference to key management"
}

variable "key_management_guid" {
  description = "Key management guid"
}

variable "cos_instance_ids" {
  description = "Map of COS instance IDs"
}

variable "cos" {
  description = "COS variable"
}

variable "use_secrets_manager" {
  description = "Use secrets manager"
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  target_key_management_service = lookup(var.key_management, "use_hs_crypto", false) == true ? "hs-crypto" : "kms"
  service_authorization_vpc_to_key_management = {
    # Create authorization to allow key management to access VPC block storage
    "block-storage" = {
      source_service_name         = "server-protect"
      description                 = "Allow block storage volumes to be encrypted by KMS instance"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
    }
  }
}

##############################################################################

##############################################################################
# COS to Key Management
##############################################################################

module "cos_to_key_management" {
  source = "../list_to_map"
  list = [
    for instance in var.cos :
    {
      name                        = "cos-${instance.name}-to-key-management"
      source_service_name         = "cloud-object-storage"
      source_resource_instance_id = split(":", var.cos_instance_ids[instance.name])[7]
      description                 = "Allow COS instance to read from KMS instance"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
    }
  ]
}

module "flow_logs_to_cos" {
  source = "../list_to_map"
  list = [
    for instance in var.cos :
    {
      name                        = "flow-logs-${instance.name}-cos"
      source_service_name         = "is"
      source_resource_type        = "flow-log-collector"
      description                 = "Allow flow logs write access cloud object storage instance"
      roles                       = ["Writer"]
      target_service_name         = "cloud-object-storage"
      target_resource_instance_id = split(":", var.cos_instance_ids[instance.name])[7]
    }
  ]
}

module "secrets_manager_to_cos" {
  source = "../list_to_map"
  list = [
    for instance in(var.use_secrets_manager ? ["secrets-manager-to-kms"] : []) :
    {
      name                        = instance
      source_service_name         = "secrets-manager"
      description                 = "Allow secrets manager to read from Key Management"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
    }
  ]
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "authorizations" {
  description = "Map of service authorizations"
  value = merge(
    local.service_authorization_vpc_to_key_management,
    module.cos_to_key_management.value,
    module.flow_logs_to_cos.value,
    module.secrets_manager_to_cos.value
  )
}

##############################################################################
