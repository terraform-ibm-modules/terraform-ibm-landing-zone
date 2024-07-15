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

variable "skip_kms_block_storage_s2s_auth_policy" {
  description = "Add kms to block storage s2s"
}

variable "skip_all_s2s_auth_policies" {
  description = "Add s2s authorization policies"
}

variable "atracker_cos_bucket" {
  description = "Add atracker to cos s2s"
}

variable "clusters" {
  description = "Add cluster to kms auth policies"
}

##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  target_key_management_service = lookup(var.key_management, "name", null) != null ? lookup(var.key_management, "use_hs_crypto", false) == true ? "hs-crypto" : "kms" : null
}

module "kms_to_block_storage" {
  source = "../list_to_map"
  list = [
    for instance in(var.skip_kms_block_storage_s2s_auth_policy ? [] : ["block-storage"]) :
    {
      name                        = instance
      source_service_name         = "server-protect"
      description                 = "Allow block storage volumes to be encrypted by KMS instance"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
    } if local.target_key_management_service != null
  ]
}

# Required service authorization access policy for Kubernetes Service and the KMS provider.
# This auth-policy only gets auto created if doing cluster data encryption.
# But for boot volume encryption, this policy needs to exist before cluster creation hence we need to explicitly create it.
module "kube_to_kms" {
  source = "../list_to_map"
  list = [
    for instance in(length(var.clusters) > 0 ? ["containers-kubernetes"] : []) :
    {
      name                        = instance
      source_service_name         = "containers-kubernetes"
      description                 = "Allow cluster to be encrypted by KMS instance"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
    } if local.target_key_management_service != null
  ]
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
    } if local.target_key_management_service != null && instance.use_data == false
  ]
}

module "flow_logs_to_cos" {
  source = "../list_to_map"
  list = [
    for instance in var.cos :
    {
      name                        = "flow-logs-${instance.name}"
      source_service_name         = "is"
      source_resource_type        = "flow-log-collector"
      description                 = "Allow flow logs write access cloud object storage instance"
      roles                       = ["Writer"]
      target_service_name         = "cloud-object-storage"
      target_resource_instance_id = split(":", var.cos_instance_ids[instance.name])[7]
    }
  ]
}

##############################################################################

##############################################################################
# Atracker to COS
##############################################################################

locals {
  atracker_cos_instance = var.atracker_cos_bucket == null ? null : flatten([
    for instance in var.cos :
    [
      for bucket in instance.buckets :
      [instance.name] if bucket.name == var.atracker_cos_bucket
    ]
  ])[0]
}

module "atracker_to_cos" {
  source = "../list_to_map"
  list = [
    for instance in(var.atracker_cos_bucket != null ? ["atracker-to-cos"] : []) :
    {
      name                        = instance
      source_service_name         = "atracker"
      description                 = "Allow atracker to write to COS"
      roles                       = ["Object Writer"]
      target_service_name         = "cloud-object-storage"
      target_resource_instance_id = split(":", var.cos_instance_ids[local.atracker_cos_instance])[7]
    }
  ]
}

##############################################################################
# Outputs
##############################################################################

output "authorizations" {
  description = "Map of service authorizations"
  value = merge(
    module.kms_to_block_storage.value,
    module.cos_to_key_management.value,
    module.flow_logs_to_cos.value,
    module.atracker_to_cos.value,
    module.kube_to_kms.value
  )
}

##############################################################################
