##############################################################################
# Bastion Host Locals
##############################################################################

locals {
  bastion_vsi_map = module.dynamic_values.bastion_vsi_map
}

##############################################################################


##############################################################################
# Configure Teleport
##############################################################################

module "teleport_config" {
  count                     = local.create_bastion_host ? 1 : 0
  source                    = "./teleport_config"
  teleport_licence          = var.teleport_config_data.teleport_license
  https_certs               = var.teleport_config_data.https_cert
  https_key                 = var.teleport_config_data.https_key
  hostname                  = var.teleport_config_data.hostname
  domain                    = var.teleport_config_data.domain
  cos_bucket                = ibm_cos_bucket.buckets[var.teleport_config_data.cos_bucket_name].bucket_name
  cos_bucket_endpoint       = ibm_cos_bucket.buckets[var.teleport_config_data.cos_bucket_name].s3_endpoint_public
  hmac_access_key_id        = ibm_resource_key.key[var.teleport_config_data.cos_key_name].credentials["cos_hmac_keys.access_key_id"]
  hmac_secret_access_key_id = ibm_resource_key.key[var.teleport_config_data.cos_key_name].credentials["cos_hmac_keys.secret_access_key"]
  appid_client_id           = ibm_resource_key.appid_key[var.teleport_config_data.app_id_key_name].credentials["clientId"]
  appid_client_secret       = ibm_resource_key.appid_key[var.teleport_config_data.app_id_key_name].credentials["secret"]
  appid_issuer_url          = ibm_resource_key.appid_key[var.teleport_config_data.app_id_key_name].credentials["oauthServerUrl"]
  teleport_version          = var.teleport_config_data.teleport_version
  claim_to_roles            = var.teleport_config_data.claims_to_roles
  message_of_the_day        = var.teleport_config_data.message_of_the_day
}

##############################################################################


##############################################################################
# Create Bastion Host
##############################################################################

module "bastion_host" {
  source                          = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version                         = "5.15.4"
  for_each                        = local.bastion_vsi_map
  resource_group_id               = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  create_security_group           = each.value.security_group == null ? false : true
  prefix                          = "${var.prefix}-${each.value.name}"
  vpc_id                          = module.vpc[each.value.vpc_name].vpc_id
  subnets                         = each.value.subnets
  access_tags                     = each.value.access_tags
  kms_encryption_enabled          = true
  skip_iam_authorization_policy   = true
  vsi_per_subnet                  = 1
  primary_vni_additional_ip_count = each.value.primary_vni_additional_ip_count
  use_legacy_network_interface    = each.value.use_legacy_network_interface
  boot_volume_encryption_key = each.value.boot_volume_encryption_key_name == null ? "" : [
    for keys in module.key_management.keys :
    keys.crn if keys.name == each.value.boot_volume_encryption_key_name
  ][0]
  image_id  = data.ibm_is_image.image["${var.prefix}-${each.value.name}"].id
  user_data = module.teleport_config[0].cloud_init
  security_group_ids = each.value.security_groups == null ? [] : [
    for group in each.value.security_groups :
    ibm_is_security_group.security_group[group].id
  ]
  ssh_key_ids = [
    for ssh_key in each.value.ssh_keys :
    module.ssh_keys.ssh_key_map[ssh_key].id
  ]
  machine_type       = each.value.machine_type
  security_group     = each.value.security_group
  enable_floating_ip = false
  depends_on         = [module.ssh_keys]
}

##############################################################################
