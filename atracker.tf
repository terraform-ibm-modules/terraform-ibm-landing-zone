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
}

##############################################################################

##############################################################################
# Activity Tracker and Route
##############################################################################

resource "ibm_atracker_target" "atracker_target" {

  count = local.valid_atracker_region && var.atracker.add_route == true ? 1 : 0

  cos_endpoint {
    endpoint                   = "s3.private.${var.region}.cloud-object-storage.appdomain.cloud"
    target_crn                 = local.bucket_to_instance_map[var.atracker.collector_bucket_name].id
    bucket                     = ibm_cos_bucket.buckets[replace(var.atracker.collector_bucket_name, var.prefix, "")].bucket_name
    service_to_service_enabled = true
  }
  name        = "${var.prefix}-atracker"
  target_type = "cloud_object_storage"

  # Wait for buckets and auth policies to ensure successful provision
  depends_on = [ibm_cos_bucket.buckets, ibm_iam_authorization_policy.policy, time_sleep.wait_for_authorization_policy_buckets]
}

resource "ibm_atracker_route" "atracker_route" {
  count = var.atracker.add_route == true && local.valid_atracker_region ? 1 : 0
  name  = "${var.prefix}-atracker-route"
  rules {
    target_ids = [
      ibm_atracker_target.atracker_target[0].id
    ]
    locations = ["*", "global"]
  }
}

##############################################################################
