##############################################################################
# Landing Zone VSI Pattern
##############################################################################

module "landing_zone" {
  source                    = "../mixed"
  prefix                    = var.prefix
  region                    = var.region
  ibmcloud_api_key          = var.ibmcloud_api_key
  ssh_public_key            = var.ssh_public_key
  override                  = var.override
  tags                      = var.tags
  network_cidr              = var.network_cidr
  vpcs                      = var.vpcs
  enable_transit_gateway    = var.enable_transit_gateway
  add_atracker_route        = var.add_atracker_route
  hs_crypto_instance_name   = var.hs_crypto_instance_name
  hs_crypto_resource_group  = var.hs_crypto_resource_group
  use_random_cos_suffix     = var.use_random_cos_suffix
  create_secrets_manager    = var.create_secrets_manager
  enable_scc                = var.enable_scc
  scc_cred_name             = var.scc_cred_name
  scc_collector_description = var.scc_collector_description
  scc_scope_description     = var.scc_scope_description
  scc_scope_name            = var.scc_scope_name
  add_kms_block_storage_s2s = var.add_kms_block_storage_s2s
  override_json_string      = var.override_json_string
}
