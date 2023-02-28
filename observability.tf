locals {
  observability_map = module.dynamic_values.clusters_map
}


##############################################################################
# Observability Instances (LogDNA + Sysdig)
##############################################################################

module "observability_instances" {
  for_each                   = local.observability_map
  source                     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-observability-instances?ref=v1.1.1"
  region                     = var.region
  resource_group_id          = local.resource_groups[each.value.resource_group]
  activity_tracker_provision = false
  logdna_instance_name       = "${each.value.cluster_name}-logdna"
  sysdig_instance_name       = "${each.value.cluster_name}-sysdig"
  logdna_plan                = each.value.logdna_plan
  sysdig_plan                = each.value.sysdig_plan
  enable_platform_logs       = each.value.enable_platform_logs
  enable_platform_metrics    = each.value.enable_platform_metrics
  logdna_tags                = var.resource_tags
  sysdig_tags                = var.resource_tags
}
