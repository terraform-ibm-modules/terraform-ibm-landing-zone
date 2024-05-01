##############################################################################
# Activity Tracker Event Routing is only supported in the following regions,
# resources will only be provisioned where supported
# https://cloud.ibm.com/docs/atracker?topic=atracker-regions#regions-atracker
##############################################################################

locals {
  valid_atracker_region = contains(
    ["us-south", "us-east", "eu-de", "eu-es", "eu-gb", "eu-fr2", "au-syd"],
    var.region
  )

  create_log_analysis_target       = local.valid_atracker_region && var.atracker.collector_log_analysis_name != null && var.atracker.add_route
  create_event_event_stream_target = local.valid_atracker_region && var.atracker.collector_event_stream_topic_name != null && var.atracker.add_route

  atracker_cos_target_id          = [ibm_atracker_target.atracker_cos_target[0].id]
  atracker_log_analysis_target_id = local.create_log_analysis_target ? [ibm_atracker_target.atracker_log_analysis_target[0].id] : []
  atracker_event_stream_target_id = local.create_event_event_stream_target ? [ibm_atracker_target.atracker_event_streams_targets[0].id] : []
  atracker_target_ids             = concat(local.atracker_cos_target_id, local.atracker_event_stream_target_id, local.atracker_log_analysis_target_id)
}

##############################################################################

resource "ibm_resource_instance" "atracker_event_log_analysis" {
  count             = local.create_log_analysis_target ? 1 : 0
  name              = var.atracker.collector_log_analysis_name
  resource_group_id = local.resource_groups[var.atracker.resource_group]
  service           = "logdna"
  plan              = "7-day"
  location          = var.region
  service_endpoints = "public-and-private"
  parameters = {
    "default_receiver" = true
  }
}

resource "ibm_resource_key" "resource_key" {
  count                = local.create_log_analysis_target ? 1 : 0
  name                 = "${var.atracker.collector_log_analysis_name}-key"
  resource_instance_id = ibm_resource_instance.atracker_event_log_analysis[0].id
  role                 = "Manager"
}
module "atracker_event_streams" {
  count             = local.create_event_event_stream_target ? 1 : 0
  source            = "terraform-ibm-modules/event-streams/ibm"
  version           = "2.0.13"
  resource_group_id = local.resource_groups[var.atracker.resource_group]
  es_name           = "${var.prefix}-atracker-event-stream"
  topics = [{
    name       = var.atracker.collector_event_stream_topic_name
    partitions = 1
    config = {
      "cleanup.policy"  = "delete"
      "retention.ms"    = "86400000"  # 1 Day
      "retention.bytes" = "10485760"  # 10 MB
      "segment.bytes"   = "536870912" #512 MB
    }
  }]
}

resource "ibm_resource_key" "atracker_event_stream_resource_key" {
  count                = local.create_event_event_stream_target ? 1 : 0
  name                 = "${var.prefix}-atracker-event-stream-key"
  resource_instance_id = module.atracker_event_streams[0].id
  role                 = "Manager"
}

##############################################################################
# Activity Tracker and Route
##############################################################################

resource "ibm_atracker_target" "atracker_cos_target" {
  count = local.valid_atracker_region && var.atracker.add_route == true ? 1 : 0
  cos_endpoint {
    endpoint                   = "s3.private.${var.region}.cloud-object-storage.appdomain.cloud"
    target_crn                 = local.bucket_to_instance_map[var.atracker.collector_bucket_name].id
    bucket                     = ibm_cos_bucket.buckets[replace(var.atracker.collector_bucket_name, var.prefix, "")].bucket_name
    service_to_service_enabled = true
  }
  name        = "${var.prefix}-cos-atracker"
  target_type = "cloud_object_storage"

  # Wait for buckets and auth policies to ensure successful provision
  depends_on = [ibm_cos_bucket.buckets, ibm_iam_authorization_policy.policy]
}

resource "ibm_atracker_target" "atracker_log_analysis_target" {
  count = local.create_log_analysis_target ? 1 : 0
  logdna_endpoint {
    target_crn    = ibm_resource_instance.atracker_event_log_analysis[0].id
    ingestion_key = ibm_resource_key.resource_key[0].credentials.ingestion_key
  }
  name        = "${var.prefix}-log-analysis-atracker"
  target_type = "logdna"
}

resource "ibm_atracker_target" "atracker_event_streams_targets" {
  count = local.create_event_event_stream_target ? 1 : 0
  eventstreams_endpoint {
    target_crn = module.atracker_event_streams[0].crn
    brokers    = module.atracker_event_streams[0].kafka_brokers_sasl
    topic      = var.atracker.collector_event_stream_topic_name
    api_key    = ibm_resource_key.atracker_event_stream_resource_key[0].credentials.apikey
  }
  name        = "${var.prefix}-event-stream-atracker"
  target_type = "event_streams"
}

resource "ibm_atracker_route" "atracker_route" {
  count = var.atracker.add_route == true && local.valid_atracker_region ? 1 : 0
  name  = "${var.prefix}-atracker-route"
  rules {
    target_ids = local.atracker_target_ids
    locations  = ["*", "global"]
  }
}

##############################################################################
