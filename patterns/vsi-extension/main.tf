##############################################################################
# Locals
##############################################################################

locals {
  ssh_key_id = var.ssh_public_key != null ? ibm_is_ssh_key.ssh_key[0].id : data.ibm_is_ssh_key.ssh_key[0].id
}

##############################################################################
# Resource Group
##############################################################################

data "ibm_resource_group" "existing_resource_group" {
  name = var.resource_group
}

##############################################################################
# SSH key
##############################################################################
resource "ibm_is_ssh_key" "ssh_key" {
  count          = local.ssh_keys != null ? 1 : 0
  name           = local.ssh_keys.name
  public_key     = replace(local.ssh_keys.public_key, "/==.*$/", "==")
  resource_group = data.ibm_resource_group.existing_resource_group.id
  tags           = var.resource_tags
}

data "ibm_is_ssh_key" "ssh_key" {
  count = var.existing_ssh_key_name == null ? 0 : 1
  name  = var.existing_ssh_key_name
}

data "ibm_is_vpc" "vpc_by_id" {
  identifier = var.vpc_id
}


data "ibm_is_image" "image" {
  name = var.image_name
}

locals {
  subnets = [
    for subnet in data.ibm_is_vpc.vpc_by_id.subnets :
    subnet if can(regex(join("|", var.subnet_names), subnet.name))
  ]
}

module "vsi" {
  source                        = "terraform-ibm-modules/landing-zone-vsi/ibm"
  version                       = "2.13.0"
  resource_group_id             = data.ibm_resource_group.existing_resource_group.id
  create_security_group         = true
  prefix                        = "${var.prefix}-vsi"
  vpc_id                        = var.vpc_id
  subnets                       = var.subnet_names != null ? local.subnets : data.ibm_is_vpc.vpc_by_id.subnets
  tags                          = var.resource_tags
  access_tags                   = var.access_tags
  kms_encryption_enabled        = true
  skip_iam_authorization_policy = var.skip_iam_authorization_policy
  user_data                     = var.user_data
  image_id                      = data.ibm_is_image.image.id
  boot_volume_encryption_key    = var.boot_volume_encryption_key
  existing_kms_instance_guid    = var.existing_kms_instance_guid
  security_group_ids            = var.security_group_ids
  ssh_key_ids                   = [local.ssh_key_id]
  machine_type                  = var.machine_type
  vsi_per_subnet                = var.vsi_per_subnet
  security_group                = local.env.security_groups[0]
  load_balancers                = var.load_balancers
  block_storage_volumes         = var.block_storage_volumes
  enable_floating_ip            = var.enable_floating_ip
  placement_group_id            = var.placement_group_id
}
