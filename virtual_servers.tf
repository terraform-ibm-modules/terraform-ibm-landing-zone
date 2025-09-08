##############################################################################
# VSI Locals
##############################################################################

locals {
  vsi_map        = module.dynamic_values.vsi_map
  ssh_keys       = module.dynamic_values.ssh_keys
  vsi_images_map = module.dynamic_values.vsi_images_map
}

##############################################################################

##############################################################################
# SSH Keys
##############################################################################

module "ssh_keys" {
  source   = "./ssh_key"
  prefix   = var.prefix
  ssh_keys = local.ssh_keys
  tags     = var.tags == null ? null : var.tags
}

##############################################################################


##############################################################################
# VSI Images
##############################################################################

data "ibm_is_image" "image" {
  for_each = local.vsi_images_map
  name     = each.value.image_name
}

##############################################################################

##############################################################################
# Create VSI Deployments
##############################################################################

module "vsi" {
  source                          = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version                         = "5.5.4"
  for_each                        = local.vsi_map
  resource_group_id               = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  create_security_group           = each.value.security_group == null ? false : true
  prefix                          = "${var.prefix}-${each.value.name}"
  vpc_id                          = module.vpc[each.value.vpc_name].vpc_id
  subnets                         = each.value.subnets
  tags                            = var.tags
  access_tags                     = each.value.access_tags
  kms_encryption_enabled          = true
  skip_iam_authorization_policy   = true
  user_data                       = lookup(each.value, "user_data", null)
  image_id                        = data.ibm_is_image.image["${var.prefix}-${each.value.name}"].id
  primary_vni_additional_ip_count = each.value.primary_vni_additional_ip_count
  use_legacy_network_interface    = each.value.use_legacy_network_interface
  boot_volume_encryption_key = each.value.boot_volume_encryption_key_name == null ? "" : [
    for keys in module.key_management.keys :
    keys.crn if keys.name == each.value.boot_volume_encryption_key_name
  ][0]
  security_group_ids = each.value.security_groups == null ? [] : [
    for group in each.value.security_groups :
    ibm_is_security_group.security_group[group].id
  ]
  ssh_key_ids = [
    for ssh_key in each.value.ssh_keys :
    module.ssh_keys.ssh_key_map[ssh_key].id
  ]
  machine_type   = each.value.machine_type
  vsi_per_subnet = each.value.vsi_per_subnet
  security_group = each.value.security_group
  load_balancers = each.value.load_balancers == null ? [] : each.value.load_balancers
  block_storage_volumes = each.value.block_storage_volumes == null ? [] : [
    # For each block storage volume
    for volume in each.value.block_storage_volumes :
    # Merge volume and add encryption key
    {
      name     = volume.name
      profile  = volume.profile
      capacity = volume.capacity
      iops     = volume.iops
      encryption_key = lookup(volume, "encryption_key", null) == null ? null : [
        for key in module.key_management.keys :
        key.crn if key.name == volume.encryption_key
      ][0]
    }
  ]
  enable_floating_ip = each.value.enable_floating_ip == true ? true : false
  allow_ip_spoofing  = each.value.allow_ip_spoofing
  depends_on         = [module.ssh_keys]
}

##############################################################################
