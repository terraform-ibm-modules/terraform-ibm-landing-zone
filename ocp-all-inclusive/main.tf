##############################################################################
# base-ocp-vpc-module
##############################################################################

locals {
  # Input variable validation
  # tflint-ignore: terraform_unused_declarations
  validate_cos_inputs = (var.use_existing_cos == false && var.cos_name == null) ? tobool("A value must be passed for var.cos_name if var.use_existing_cos is false.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_existing_cos_inputs = (var.use_existing_cos == true && var.existing_cos_id == null) ? tobool("A value must be passed for var.existing_cos_id if var.use_existing_cos is true.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_kp_inputs = (var.existing_key_protect_instance_guid == null && var.existing_key_protect_root_key_id != null) || (var.existing_key_protect_root_key_id != null && var.existing_key_protect_instance_guid == null) ? tobool("To enable encryption, values must be passed for both var.existing_key_protect_instance_guid and var.existing_key_protect_root_key_id. Set them both to null to create cluster without encryption (not recommended).") : true

  # If encryption enabled generate kms config to be passed to cluster
  kms_config = var.existing_key_protect_instance_guid != null && var.existing_key_protect_root_key_id != null ? {
    crk_id           = var.existing_key_protect_root_key_id
    instance_id      = var.existing_key_protect_instance_guid
    private_endpoint = var.key_protect_use_private_endpoint
  } : null
}

module "ocp_base" {
  source                          = "git::https://github.ibm.com/GoldenEye/base-ocp-vpc-module.git?ref=2.1.1"
  cluster_name                    = var.cluster_name
  ocp_version                     = var.ocp_version
  resource_group_id               = var.resource_group_id
  region                          = var.region
  tags                            = var.cluster_tags
  force_delete_storage            = var.force_delete_storage
  vpc_id                          = var.vpc_id
  vpc_subnets                     = var.vpc_subnets
  worker_pools                    = var.worker_pools
  cluster_ready_when              = var.cluster_ready_when
  worker_pools_taints             = var.worker_pools_taints
  cos_name                        = var.cos_name
  use_existing_cos                = var.use_existing_cos
  existing_cos_id                 = var.existing_cos_id
  ocp_entitlement                 = var.ocp_entitlement
  disable_public_endpoint         = var.disable_public_endpoint
  ignore_worker_pool_size_changes = var.ignore_worker_pool_size_changes
  kms_config                      = local.kms_config
}


##############################################################################
# observability-agents-module
##############################################################################

locals {
  # Locals
  run_observability_agents_module = (local.provision_logdna_agent == true || local.provision_sysdig_agent || local.provision_logdna_sts_agent) ? true : false
  provision_logdna_agent          = var.logdna_instance_name != null ? true : false
  provision_sysdig_agent          = var.sysdig_instance_name != null ? true : false
  provision_logdna_sts_agent      = var.logdna_sts_instance_name != null ? true : false
  logdna_resource_group_id        = var.logdna_resource_group_id != null ? var.logdna_resource_group_id : var.resource_group_id
  sysdig_resource_group_id        = var.sysdig_resource_group_id != null ? var.sysdig_resource_group_id : var.resource_group_id
  logdna_sts_resource_group_id    = var.logdna_sts_resource_group_id != null ? var.logdna_sts_resource_group_id : var.resource_group_id

  # Some input variable validation (approach based on https://stackoverflow.com/a/66682419)
  logdna_validate_condition = var.logdna_instance_name != null && var.logdna_ingestion_key == null
  logdna_validate_msg       = "A value for var.logdna_ingestion_key must be passed when providing a value for var.logdna_instance_name"
  # tflint-ignore: terraform_unused_declarations
  logdna_validate_check     = regex("^${local.logdna_validate_msg}$", (!local.logdna_validate_condition ? local.logdna_validate_msg : ""))
  sysdig_validate_condition = var.sysdig_instance_name != null && var.sysdig_access_key == null
  sysdig_validate_msg       = "A value for var.sysdig_access_key must be passed when providing a value for var.sysdig_instance_name"
  # tflint-ignore: terraform_unused_declarations
  sysdig_validate_check         = regex("^${local.sysdig_validate_msg}$", (!local.sysdig_validate_condition ? local.sysdig_validate_msg : ""))
  logdna_sts_validate_condition = var.logdna_sts_instance_name != null && var.logdna_sts_ingestion_key == null
  logdna_sts_validate_msg       = "A value for var.logdna_sts_ingestion_key must be passed when providing a value for var.logdna_sts_instance_name"
  # tflint-ignore: terraform_unused_declarations
  logdna_sts_validate_check = regex("^${local.logdna_sts_validate_msg}$", (!local.logdna_sts_validate_condition ? local.logdna_sts_validate_msg : ""))
}

module "observability_agents" {
  # cluster-proxy required so observability images can be pulled from public registry
  count                        = local.run_observability_agents_module == true ? 1 : 0
  source                       = "git::https://github.ibm.com/GoldenEye/observability-agents-module?ref=2.4.6"
  cluster_id                   = module.ocp_base.cluster_id
  cluster_resource_group_id    = var.resource_group_id
  logdna_enabled               = local.provision_logdna_agent
  logdna_instance_name         = var.logdna_instance_name
  logdna_ingestion_key         = var.logdna_ingestion_key
  logdna_resource_group_id     = local.logdna_resource_group_id
  logdna_agent_version         = var.logdna_agent_version
  sysdig_enabled               = local.provision_sysdig_agent
  sysdig_instance_name         = var.sysdig_instance_name
  sysdig_access_key            = var.sysdig_access_key
  sysdig_resource_group_id     = local.sysdig_resource_group_id
  sysdig_agent_version         = var.sysdig_agent_version
  logdna_sts_provision         = local.provision_logdna_sts_agent
  logdna_sts_instance_name     = var.logdna_sts_instance_name
  logdna_sts_ingestion_key     = var.logdna_sts_ingestion_key
  logdna_sts_resource_group_id = local.logdna_sts_resource_group_id
  logdna_sts_agent_version     = var.logdna_sts_agent_version
}

##############################################################################
# ocp-service-mesh-module
##############################################################################

locals {
  run_service_mesh_module = length(var.service_mesh_control_planes) != 0 ? true : false
}

module "service_mesh" {

  # cluster-proxy required so service mesh images can be pulled from public registry
  # Prateek : TBD - THis has to be checked as cluster proxy is not present here but need to pull Images
  depends_on                  = [module.cluster_proxy]
  count                       = local.run_service_mesh_module == true ? 1 : 0
  source                      = "../ocp-service-mesh"
  cluster_id                  = module.ocp_base.cluster_id
  service_mesh_control_planes = var.service_mesh_control_planes
  # supplying both of the subnet variables so that ALB and NLB will work, and is safe to provide both
  lb_subnet_ids           = [for subnet in lookup(var.vpc_subnets, "edge") : lookup(subnet, "id")]
  lb_subnet_ids_and_zones = { for subnet in lookup(var.vpc_subnets, "edge") : lookup(subnet, "id") => lookup(subnet, "zone") }
}
