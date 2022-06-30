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
  TELEPORT_LICENSE          = var.teleport_config_data.teleport_license
  HTTPS_CERT                = var.teleport_config_data.https_cert
  HTTPS_KEY                 = var.teleport_config_data.https_key
  HOSTNAME                  = var.teleport_config_data.hostname
  DOMAIN                    = var.teleport_config_data.domain
  COS_BUCKET                = ibm_cos_bucket.buckets[var.teleport_config_data.cos_bucket_name].bucket_name
  COS_BUCKET_ENDPOINT       = ibm_cos_bucket.buckets[var.teleport_config_data.cos_bucket_name].s3_endpoint_public
  HMAC_ACCESS_KEY_ID        = ibm_resource_key.key[var.teleport_config_data.cos_key_name].credentials["cos_hmac_keys.access_key_id"]
  HMAC_SECRET_ACCESS_KEY_ID = ibm_resource_key.key[var.teleport_config_data.cos_key_name].credentials["cos_hmac_keys.secret_access_key"]
  APPID_CLIENT_ID           = ibm_resource_key.appid_key[var.teleport_config_data.app_id_key_name].credentials["clientId"]
  APPID_CLIENT_SECRET       = ibm_resource_key.appid_key[var.teleport_config_data.app_id_key_name].credentials["secret"]
  APPID_ISSUER_URL          = ibm_resource_key.appid_key[var.teleport_config_data.app_id_key_name].credentials["oauthServerUrl"]
  TELEPORT_VERSION          = var.teleport_config_data.teleport_version
  CLAIM_TO_ROLES            = var.teleport_config_data.claims_to_roles
  MESSAGE_OF_THE_DAY        = var.teleport_config_data.message_of_the_day
}

##############################################################################


##############################################################################
# Create Bastion Host
##############################################################################

module "bastion_host" {
  source                = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi.git?ref=init-vsi-mod"
  for_each              = local.bastion_vsi_map
  resource_group_id     = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  create_security_group = each.value.security_group == null ? false : true
  prefix                = "${var.prefix}-${each.value.name}"
  vpc_id                = module.vpc[each.value.vpc_name].vpc_id
  subnets               = each.value.subnets
  vsi_per_subnet        = 1
  boot_volume_encryption_key = each.value.boot_volume_encryption_key_name == null ? "" : [
    for keys in module.key_management.keys :
    keys.id if keys.name == each.value.boot_volume_encryption_key_name
  ][0]
  image_id  = data.ibm_is_image.image["${var.prefix}-${each.value.name}"].id
  user_data = module.teleport_config[0].cloud_init
  security_group_ids = each.value.security_groups == null ? [] : [
    for group in each.value.security_groups :
    ibm_is_security_group.security_group[group].id
  ]
  ssh_key_ids = [
    for ssh_key in each.value.ssh_keys :
    lookup(module.ssh_keys.ssh_key_map, ssh_key).id
  ]
  machine_type       = each.value.machine_type
  security_group     = each.value.security_group
  enable_floating_ip = false
  depends_on         = [module.ssh_keys]
}

##############################################################################
