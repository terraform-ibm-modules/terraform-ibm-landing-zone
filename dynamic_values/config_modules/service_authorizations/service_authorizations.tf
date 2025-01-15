##############################################################################
# Variables
##############################################################################

variable "key_management" {
  description = "Direct reference to key management"
}

variable "key_management_guid" {
  description = "Key management guid"
}

variable "key_management_key_map" {
  description = "Key management key IDs"
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

variable "skip_kms_kube_s2s_auth_policy" {
  description = "Add kms to kubernetes s2s"
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

variable "vsi" {
  description = "Add vsi block storage to auth policies"
}

variable "vpcs" {
  description = "Direct reference to vpcs variable"
}

##############################################################################

##############################################################################
# BUCKET MAP
# Create a flattened out map of all configured cos buckets.
# This map will have the bucket name as the key, and have attributes
# from both the bucket and the parent instance that we need in further queries.
# This map will be used to perform lookups based on bucket name to get data related to either
# the bucket itself or its parent instance.
##############################################################################
module "cos_bucket_map" {
  source = "../list_to_map"
  list = flatten([
    for instance in var.cos :
    [
      for bucket in instance.buckets :
      [
        {
          name                          = bucket.name
          instance_name                 = instance.name
          bucket_key_name               = lookup(bucket, "kms_key", null)
          skip_kms_s2s_auth_policy      = lookup(instance, "skip_kms_s2s_auth_policy", false)
          skip_flowlogs_s2s_auth_policy = lookup(instance, "skip_flowlogs_s2s_auth_policy", false)
          skip_atracker_s2s_auth_policy = lookup(instance, "skip_atracker_s2s_auth_policy", false)
        }
      ]
    ]
  ])
}

##############################################################################
# Locals
##############################################################################

locals {
  target_key_management_service = lookup(var.key_management, "name", null) != null ? lookup(var.key_management, "use_hs_crypto", false) == true ? "hs-crypto" : "kms" : null

  # create a list of keys used for all buckets, since we are going to scope the auth policy to keys.
  # doing this in a local first becase it needs a distinct to get rid of duplicates from same keys used
  # on multiple buckets, and a distinct on the final map may error in terraform for_each before first apply.
  cos_bucket_key_list_distinct = distinct(
    flatten([
      for bucket in module.cos_bucket_map.value :
      [
        {
          instance_name   = bucket.instance_name
          bucket_key_name = lookup(bucket, "bucket_key_name", null)
        }
      ] if !bucket.skip_kms_s2s_auth_policy
    ])
  )

  # get all keys that will be used for VSI block storage
  # this is combination of all boot volume keys, plus the extra storage volume keys
  block_storage_key_list_distinct = distinct(
    flatten([
      [
        for vsi in var.vsi :
        [
          { block_key_name = lookup(vsi, "boot_volume_encryption_key_name", null) }
        ]
      ],
      [
        for vsi in var.vsi :
        [
          for block in coalesce(lookup(vsi, "block_storage_volumes", null), []) :
          [
            { block_key_name = lookup(block, "encryption_key", null) }
          ]
        ]
      ]
    ])
  )

  # get all keys used in clusters
  # is combination of boot keys and config keys
  kube_key_list_distinct = distinct(
    flatten([
      [
        for cluster in var.clusters :
        [
          { cluster_key_name = lookup(cluster, "boot_volume_crk_name", null) }
        ]
      ],
      [
        for cluster in var.clusters :
        [
          { cluster_key_name = lookup(cluster.kms_config, "crk_name", null) }
        ] if lookup(cluster, "kms_config", null) != null
      ]
    ])
  )
}

module "kms_to_block_storage" {
  source = "../list_to_map"
  list = [
    for instance in local.block_storage_key_list_distinct :
    {
      name                        = "block-storage-to-${instance.block_key_name}"
      source_service_name         = "server-protect"
      description                 = "Allow block storage volumes to be encrypted by KMS key"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
      target_resource_type        = "key"
      target_resource_id          = split(":", var.key_management_key_map[instance.block_key_name].crn)[9]
      target_resource_account_id  = trimprefix(split(":", var.key_management_key_map[instance.block_key_name].crn)[6], "a/")
    } if local.target_key_management_service != null && !var.skip_kms_block_storage_s2s_auth_policy && instance.block_key_name != null
  ]
}

# Required service authorization access policy for Kubernetes Service and the KMS provider.
# This auth-policy only gets auto created if doing cluster data encryption.
# But for boot volume encryption, this policy needs to exist before cluster creation hence we need to explicitly create it.
module "kube_to_kms" {
  source = "../list_to_map"
  list = [
    for instance in local.kube_key_list_distinct :
    {
      name                        = "kube-to-${instance.cluster_key_name}"
      source_service_name         = "containers-kubernetes"
      description                 = "Allow cluster to be encrypted by KMS instance"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
      target_resource_type        = "key"
      target_resource_id          = split(":", var.key_management_key_map[instance.cluster_key_name].crn)[9]
      target_resource_account_id  = trimprefix(split(":", var.key_management_key_map[instance.cluster_key_name].crn)[6], "a/")
    } if local.target_key_management_service != null && !var.skip_kms_kube_s2s_auth_policy && instance.cluster_key_name != null
  ]
}

##############################################################################

##############################################################################
# COS to Key Management
##############################################################################

module "cos_to_key_management" {
  source = "../list_to_map"
  list = [
    for bucket_key in local.cos_bucket_key_list_distinct :
    {
      name                        = "cos-${bucket_key.instance_name}-to-key-${bucket_key.bucket_key_name}"
      source_service_name         = "cloud-object-storage"
      source_resource_instance_id = split(":", var.cos_instance_ids[bucket_key.instance_name])[7]
      description                 = "Allow COS instance to read KMS key"
      roles                       = ["Reader"]
      target_service_name         = local.target_key_management_service
      target_resource_instance_id = var.key_management_guid
      target_resource_type        = "key"
      target_resource_id          = split(":", var.key_management_key_map[bucket_key.bucket_key_name].crn)[9]
      target_resource_account_id  = trimprefix(split(":", var.key_management_key_map[bucket_key.bucket_key_name].crn)[6], "a/")
    } if local.target_key_management_service != null && bucket_key.bucket_key_name != null
  ]
}

##############################################################################
# VPC Flow Logs to COS bucket
##############################################################################
locals {
  flow_log_bucket_list_distinct = distinct(
    flatten([
      for vpc in var.vpcs :
      [
        {
          bucket_name = vpc.flow_logs_bucket_name
        }
      ] if lookup(vpc, "flow_logs_bucket_name", null) != null
    ])
  )
}

# NOTE:
# Due to terraform plan cycle issues, we cannot reference the true bucket instance here in this module,
# so we will pass back the reference name of the bucket in `target_resource_id` and look up details 
# when applying the auth policy
module "flow_logs_to_cos" {
  source = "../list_to_map"
  list = [
    for instance in local.flow_log_bucket_list_distinct :
    {
      name                        = "flow-logs-${instance.bucket_name}"
      source_service_name         = "is"
      source_resource_type        = "flow-log-collector"
      description                 = "Allow flow logs write access cloud object storage instance"
      roles                       = ["Writer"]
      target_service_name         = "cloud-object-storage"
      target_resource_instance_id = null
      target_resource_type        = "bucket"
      target_resource_id          = instance.bucket_name
      target_resource_account_id  = null
    } if !module.cos_bucket_map.value[instance.bucket_name].skip_flowlogs_s2s_auth_policy
  ]
}

##############################################################################

##############################################################################
# Atracker to COS
##############################################################################

# NOTE:
# Due to terraform plan cycle issues, we cannot reference the true bucket instance here in this module,
# so we will pass back the reference name of the bucket in `target_resource_id` and look up details 
# when applying the auth policy
module "atracker_to_cos" {
  source = "../list_to_map"
  list = [
    for instance in ["atracker-to-cos"] :
    {
      name                        = instance
      source_service_name         = "atracker"
      description                 = "Allow atracker to write to COS bucket"
      roles                       = ["Object Writer"]
      target_service_name         = "cloud-object-storage"
      target_resource_instance_id = null
      target_resource_type        = "bucket"
      target_resource_id          = var.atracker_cos_bucket
      target_resource_account_id  = null
    } if var.atracker_cos_bucket != null && !try(module.cos_bucket_map.value[var.atracker_cos_bucket].skip_atracker_s2s_auth_policy, false)
  ]
}
# DEV NOTE: needed a `try()` on the `cos_bucket_map` lookup above to take care of the case where atracker is turned off
# and a bucket name is NULL. This causes plan errors which the try should catch.

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
