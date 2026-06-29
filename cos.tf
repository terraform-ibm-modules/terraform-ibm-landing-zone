##############################################################################
# Cloud Object Storage Locals
##############################################################################

locals {
  cos_location           = "global"
  cos_instance_ids       = module.dynamic_values.cos_instance_ids
  cos_data_map           = module.dynamic_values.cos_data_map
  cos_map                = module.dynamic_values.cos_map
  buckets_map            = module.dynamic_values.cos_bucket_map
  cos_key_map            = module.dynamic_values.cos_key_map
  bucket_to_instance_map = module.dynamic_values.bucket_to_instance_map
}

##############################################################################


##############################################################################
# Random Suffix
##############################################################################

resource "random_string" "random_cos_suffix" {
  length  = 8
  special = false
  upper   = false
}

##############################################################################

##############################################################################
# Cloud Object Storage Instances
##############################################################################

data "ibm_resource_instance" "cos" {
  for_each          = local.cos_data_map
  name              = each.value.name
  location          = local.cos_location
  resource_group_id = local.resource_groups[each.value.resource_group]
  service           = "cloud-object-storage"
}

resource "ibm_resource_instance" "cos" {
  for_each          = local.cos_map
  name              = "${var.prefix}-${each.value.name}${each.value.random_suffix == true ? "-${random_string.random_cos_suffix.result}" : ""}"
  resource_group_id = local.resource_groups[each.value.resource_group]
  service           = "cloud-object-storage"
  location          = local.cos_location
  plan              = each.value.plan
  tags              = (var.tags != null ? var.tags : null)
}

resource "ibm_resource_tag" "cos_tag" {
  for_each    = local.cos_map
  resource_id = ibm_resource_instance.cos[each.key].crn
  tag_type    = "access"
  tags        = each.value.access_tags
}

##############################################################################


##############################################################################
# COS Instance Keys
##############################################################################

resource "ibm_resource_key" "key" {
  for_each             = local.cos_key_map
  name                 = "${var.prefix}-${each.value.name}${each.value.random_suffix == "true" ? "-${random_string.random_cos_suffix.result}" : ""}"
  role                 = each.value.role
  resource_instance_id = local.cos_instance_ids[each.value.instance]
  tags                 = (var.tags != null ? var.tags : null)
  parameters           = each.value.parameters
}

##############################################################################

##############################################################################
# Cloud Object Storage Buckets
##############################################################################

resource "ibm_cos_bucket" "buckets" {
  for_each = local.buckets_map

  depends_on = [
    time_sleep.wait_for_authorization_policy
  ]

  bucket_name           = "${var.prefix}-${each.value.name}${each.value.random_suffix == "true" ? "-${random_string.random_cos_suffix.result}" : ""}"
  resource_instance_id  = local.cos_instance_ids[each.value.instance]
  storage_class         = each.value.storage_class
  endpoint_type         = coalesce(each.value.endpoint_type, "public")
  force_delete          = each.value.force_delete
  single_site_location  = each.value.single_site_location
  region_location       = (each.value.region_location == null && each.value.single_site_location == null && each.value.cross_region_location == null) ? var.region : each.value.region_location
  cross_region_location = each.value.cross_region_location
  allowed_ip            = each.value.allowed_ip
  hard_quota            = each.value.hard_quota
  key_protect = each.value.kms_key == null ? null : [
    for key in module.key_management.keys :
    key.crn if key.name == each.value.kms_key
  ][0]

  dynamic "activity_tracking" {
    for_each = (
      each.value.activity_tracking == null
      ? []
      : [each.value.activity_tracking]
    )

    content {
      activity_tracker_crn = activity_tracking.value.activity_tracker_crn
      read_data_events     = activity_tracking.value.read_data_events
      write_data_events    = activity_tracking.value.write_data_events
      management_events    = activity_tracking.value.management_events
    }
  }

  dynamic "metrics_monitoring" {
    for_each = (
      each.value.metrics_monitoring == null
      ? []
      : [each.value.metrics_monitoring]
    )

    content {
      metrics_monitoring_crn  = metrics_monitoring.value.metrics_monitoring_crn
      request_metrics_enabled = metrics_monitoring.value.request_metrics_enabled
      usage_metrics_enabled   = metrics_monitoring.value.usage_metrics_enabled
    }
  }

  dynamic "retention_rule" {
    for_each = (
      each.value.retention_rule == null
      ? []
      : [each.value.retention_rule]
    )

    content {
      default   = retention_rule.value.default
      minimum   = retention_rule.value.minimum
      maximum   = retention_rule.value.maximum
      permanent = retention_rule.value.permanent
    }
  }

  dynamic "object_versioning" {
    for_each = (
      each.value.object_versioning_enabled == true
      ? [each.value.object_versioning_enabled]
      : []
    )

    content {
      enable = each.value.object_versioning_enabled
    }
  }
}

resource "time_sleep" "wait_for_cos_bucket_lifecycle" {
  count = length(local.buckets_map) > 0 ? 1 : 0

  # workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5778
  create_duration = "90s"
}

resource "ibm_cos_bucket_lifecycle_configuration" "cos_bucket_lifecycle" {
  for_each = {
    for key, value in local.buckets_map :
    key => value if(
      value.expire_rule != null || value.archive_rule != null
    )
  }

  depends_on = [time_sleep.wait_for_cos_bucket_lifecycle]

  bucket_crn      = ibm_cos_bucket.buckets[each.key].crn
  bucket_location = compact([var.region, each.value.cross_region_location, each.value.single_site_location])[0]
  endpoint_type   = coalesce(each.value.endpoint_type, "public")

  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple expiration blocks.
    ## This block is only used to conditionally add expiration block depending on expire rule is enabled.
    for_each = (
      each.value.expire_rule == null
      ? []
      : [each.value.expire_rule]
    )
    content {
      expiration {
        days = lookup(lifecycle_rule.value, "days", null)
      }
      filter {
        prefix = lookup(lifecycle_rule.value, "expire_filter_prefix", "")
      }
      rule_id = "expiry-rule"
      status  = "enable"
    }
  }
  dynamic "lifecycle_rule" {
    ## This for_each block is NOT a loop to attach to multiple transition blocks.
    ## This block is only used to conditionally add retention block depending on archive rule is enabled.
    for_each = (
      each.value.archive_rule == null
      ? []
      : [each.value.archive_rule]
    )
    content {
      transition {
        days = lookup(lifecycle_rule.value, "days", null)

        ## The new values changed from Capatalized to all Upper case, avoid having to change values in new release
        storage_class = upper(lookup(lifecycle_rule.value, "type", ""))
      }
      filter {
        prefix = lookup(lifecycle_rule.value, "archive_filter_prefix", "")
      }
      rule_id = "archive-rule"
      status  = "enable"
    }
  }
}

resource "ibm_resource_tag" "bucket_tag" {
  for_each    = local.buckets_map
  resource_id = ibm_cos_bucket.buckets[each.key].crn
  tag_type    = "access"
  tags        = each.value.access_tags
}

##############################################################################
# Bucket backup policies
##############################################################################

locals {
  # Flatten backup vaults to create from all buckets
  backup_vaults_to_create = flatten([
    for bucket_key, bucket_value in local.buckets_map : [
      for policy in(bucket_value.backup_policies != null ? bucket_value.backup_policies : []) : {
        key                    = "${bucket_key}-${policy.backup_vault_name}"
        vault_name             = policy.backup_vault_name
        instance               = bucket_value.instance
        bucket_key             = bucket_key
        policy_name            = policy.policy_name
        region                 = bucket_value.region_location
        kms_encryption_enabled = policy.backup_vault_kms_encryption_enabled != null ? policy.backup_vault_kms_encryption_enabled : false
        kms_key_crn            = policy.backup_vault_kms_key_crn
      } if policy.backup_vault_name != null
    ]
  ])

  # Create a map of unique backup vaults to create (deduplicate by vault_name and instance)
  # Group by instance-vault_name combination and take the first occurrence
  backup_vaults_map = {
    for key, vaults in {
      for v in local.backup_vaults_to_create :
      "${v.instance}-${v.vault_name}" => v...
    } :
    key => vaults[0]
  }

  # Flatten backup policies from all buckets
  backup_policies_flat = flatten([
    for bucket_key, bucket_value in local.buckets_map : [
      for policy in(bucket_value.backup_policies != null ? bucket_value.backup_policies : []) : {
        key                       = "${bucket_key}-${policy.policy_name}"
        bucket_key                = bucket_key
        bucket_name               = "${var.prefix}-${bucket_value.name}${bucket_value.random_suffix == "true" ? "-${random_string.random_cos_suffix.result}" : ""}"
        instance                  = bucket_value.instance
        policy_name               = policy.policy_name
        target_backup_vault_crn   = policy.target_backup_vault_crn != null ? policy.target_backup_vault_crn : (policy.backup_vault_name != null ? module.backup_vault["${bucket_value.instance}-${policy.backup_vault_name}"].backup_vault_crn : null)
        backup_type               = "continuous"
        initial_delete_after_days = policy.initial_delete_after_days
      }
    ]
  ])

  # Prepare service_map for s2s-auth module
  backup_vault_service_map = {
    for policy in local.backup_policies_flat :
    policy.key => {
      source_service_name         = "cloud-object-storage"
      target_service_name         = "cloud-object-storage"
      roles                       = ["Backup Manager", "Writer"]
      description                 = "S2S authorization for COS backup from bucket ${policy.bucket_name}"
      source_service_account_id   = null
      source_resource_instance_id = split(":", local.cos_instance_ids[policy.instance])[7]
      target_resource_instance_id = coalescelist(split(":", policy.target_backup_vault_crn))[7]
      source_resource_group_id    = null
      target_resource_group_id    = null
      source_resource_type        = "bucket"
      target_resource_type        = "backup-vault"
      subject_attributes          = []
      resource_attributes         = []
    }
  }
}

# Create backup vaults using the terraform-ibm-cos backup_vault module
module "backup_vault" {
  source  = "terraform-ibm-modules/cos/ibm//modules/backup_vault"
  version = "10.16.5"

  for_each = local.backup_vaults_map

  name                     = each.value.vault_name
  add_name_suffix          = false
  existing_cos_instance_id = local.cos_instance_ids[each.value.instance]
  region                   = coalesce(each.value.region, "us-south")
  kms_encryption_enabled   = each.value.kms_encryption_enabled
  kms_key_crn              = each.value.kms_key_crn
}

# Create IAM authorization policies using s2s-auth module
module "backup_vault_s2s_auth" {
  source  = "terraform-ibm-modules/s2s-auth/ibm"
  version = "2.3.0"

  count = length(local.backup_vault_service_map) > 0 && !var.skip_all_s2s_auth_policies ? 1 : 0

  service_map = local.backup_vault_service_map
  enable_cbr  = false
}

# Wait for auth policy to be fully synced on the backend before creating backup policy
resource "time_sleep" "wait_for_backup_vault_authorization_policy" {
  depends_on       = [module.backup_vault_s2s_auth]
  count            = length(local.backup_vault_service_map) > 0 && !var.skip_all_s2s_auth_policies ? 1 : 0
  create_duration  = "30s"
  destroy_duration = "30s"
}

# Create backup policies
resource "ibm_cos_backup_policy" "backup_policy" {
  depends_on = [time_sleep.wait_for_backup_vault_authorization_policy]
  for_each   = { for policy in local.backup_policies_flat : policy.key => policy }

  bucket_crn                = ibm_cos_bucket.buckets[each.value.bucket_key].crn
  policy_name               = each.value.policy_name
  target_backup_vault_crn   = each.value.target_backup_vault_crn
  backup_type               = each.value.backup_type
  initial_delete_after_days = each.value.initial_delete_after_days
}

##############################################################################
##############################################################################
