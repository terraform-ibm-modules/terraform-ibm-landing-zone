##############################################################################
# Cluster Locals
##############################################################################

locals {
  clusters_map = module.dynamic_values.clusters_map # Convert list to map
}

##############################################################################
# Create ROKS on VPC Cluster
##############################################################################


module "cluster" {
  depends_on = [
    module.vpc
  ]
  for_each          = local.clusters_map
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-base-ocp-vpc.git?ref=v2.1.1"
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = local.resource_groups[each.value.resource_group]
  region            = var.region
  cluster_name      = each.value.cluster_name
  vpc_id            = each.value.vpc_id
  ocp_entitlement   = each.value.entitlement
  vpc_subnets = {
    vsi-zone-1 = [
      for zone in each.value.subnets :
      {
        id         = zone.id
        zone       = zone.zone
        cidr_block = zone.cidr
      }
    ]
  }
  worker_pools = concat(
    [
      {
        subnet_prefix    = each.value.subnet_names[0]
        pool_name        = "default"
        machine_type     = each.value.machine_type
        workers_per_zone = each.value.workers_per_subnet
      }
    ],
    [
      for pool in each.value.worker_pools :
      {
        subnet_prefix    = pool.subnet_names[0]
        pool_name        = pool.name
        machine_type     = pool.flavor
        workers_per_zone = pool.workers_per_subnet
      }
  ])
  ocp_version             = each.value.ocp_version
  tags                    = var.resource_tags
  use_existing_cos        = true
  disable_public_endpoint = each.value.disable_public_endpoint
  existing_cos_id         = each.value.cos_instance_crn
  kms_config = {
    instance_id = module.key_management.key_management_guid
    crk_id      = module.key_management.key_map[each.value.kms_config.crk_name].key_id
  }
}
