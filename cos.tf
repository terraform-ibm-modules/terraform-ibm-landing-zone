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

  depends_on = [time_sleep.wait_for_authorization_policy]

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
