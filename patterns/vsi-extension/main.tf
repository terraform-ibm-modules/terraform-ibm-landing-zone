##############################################################################
# Schematics Data
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_vpc_vars = var.prerequisite_workspace_id == null && var.vpc_id == null ? tobool("var.prerequisite_workspace_id and var.vpc_id cannot be both set to null.") : true
  # tflint-ignore: terraform_unused_declarations
  validate_vpc_names = var.prerequisite_workspace_id != null && var.existing_vpc_name == null ? tobool("A value must be passed for var.existing_vpc_name to choose a VPC from the list of VPCs from the schematics workspace.") : true

  location         = var.prerequisite_workspace_id != null ? regex("^[a-z/-]+", var.prerequisite_workspace_id) : null
  fullstack_output = length(data.ibm_schematics_output.schematics_output) > 0 ? jsondecode(data.ibm_schematics_output.schematics_output[0].output_json) : null
  vpc_id = var.prerequisite_workspace_id != null ? [
    for vpc in local.fullstack_output[0].vpc_data.value :
    vpc.vpc_data.id if vpc.vpc_data.name == var.existing_vpc_name
  ][0] : var.vpc_id
}

data "ibm_schematics_workspace" "schematics_workspace" {
  count        = var.prerequisite_workspace_id != null ? 1 : 0
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
}

data "ibm_schematics_output" "schematics_output" {
  count        = var.prerequisite_workspace_id != null ? 1 : 0
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
  template_id  = data.ibm_schematics_workspace.schematics_workspace[0].runtime_data[0].id
}

##############################################################################
# Locals
##############################################################################

locals {
  ssh_key_id = var.ssh_public_key != null ? ibm_is_ssh_key.ssh_key[0].id : data.ibm_is_ssh_key.ssh_key[0].id
}

##############################################################################
# SSH key
##############################################################################
resource "ibm_is_ssh_key" "ssh_key" {
  count          = local.ssh_keys != null ? 1 : 0
  name           = local.ssh_keys.name
  public_key     = replace(local.ssh_keys.public_key, "/==.*$/", "==")
  resource_group = data.ibm_is_vpc.vpc_by_id.resource_group
  tags           = var.resource_tags
}

data "ibm_is_ssh_key" "ssh_key" {
  count = var.existing_ssh_key_name == null ? 0 : 1
  name  = var.existing_ssh_key_name
}

data "ibm_is_vpc" "vpc_by_id" {
  identifier = local.vpc_id
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
  resource_group_id             = data.ibm_is_vpc.vpc_by_id.resource_group
  create_security_group         = true
  prefix                        = "${var.prefix}-vsi"
  vpc_id                        = local.vpc_id
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
