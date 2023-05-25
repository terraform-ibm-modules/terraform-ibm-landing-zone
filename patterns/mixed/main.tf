##############################################################################
# IBM Cloud Provider
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 60
}

##############################################################################


##############################################################################
# Landing Zone
##############################################################################

module "landing_zone" {
  source                         = "../../"
  prefix                         = var.prefix
  region                         = var.region
  tags                           = var.tags
  access_tags                    = var.access_tags
  resource_groups                = local.env.resource_groups
  network_cidr                   = local.env.network_cidr
  vpcs                           = local.env.vpcs
  vpn_gateways                   = local.env.vpn_gateways
  enable_transit_gateway         = local.env.enable_transit_gateway
  transit_gateway_resource_group = local.env.transit_gateway_resource_group
  transit_gateway_connections    = local.env.transit_gateway_connections
  ssh_keys                       = local.env.ssh_keys
  vsi                            = local.env.vsi
  security_groups                = local.env.security_groups
  virtual_private_endpoints      = local.env.virtual_private_endpoints
  cos                            = local.env.cos
  service_endpoints              = local.env.service_endpoints
  key_management                 = local.env.key_management
  add_kms_block_storage_s2s      = local.env.add_kms_block_storage_s2s
  atracker                       = local.env.atracker
  clusters                       = local.env.clusters
  wait_till                      = local.env.wait_till
  iam_account_settings           = local.env.iam_account_settings
  access_groups                  = local.env.access_groups
  f5_vsi                         = local.env.f5_vsi
  f5_template_data               = local.env.f5_template_data
  appid                          = local.env.appid
  teleport_config_data           = local.env.teleport_config
  teleport_vsi                   = local.env.teleport_vsi
  secrets_manager                = local.env.secrets_manager
  vpc_placement_groups           = local.env.vpc_placement_groups
  # If enable_scc is true, pass the credential created from the pattern to landing_zone. Credential is created in the pattern since it uses the IBM Cloud API key
  security_compliance_center = merge(
    local.env.security_compliance_center,
    { credential_id = var.enable_scc ? ibm_scc_posture_credential.credentials[0].id : null }
  )
}

##############################################################################

##############################################################################
# Security and Compliance Center
##############################################################################

resource "ibm_scc_posture_credential" "credentials" {
  count       = var.enable_scc ? 1 : 0
  description = var.scc_cred_description
  display_fields {
    ibm_api_key = var.ibmcloud_api_key
  }
  enabled = true
  name    = var.scc_cred_name
  purpose = "discovery_fact_collection_remediation"
  type    = "ibm_cloud"
}

##############################################################################
