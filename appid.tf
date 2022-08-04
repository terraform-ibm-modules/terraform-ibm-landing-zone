##############################################################################
# App ID Locals
##############################################################################

locals {

  # Create teleport
  create_bastion_host = length(var.teleport_vsi) > 0

  # Create appid instance or get from data
  create_appid = (
    local.create_bastion_host == false
    ? false                                       # false if not used
    : lookup(var.appid, "use_data", null) == true # if use data true
    ? "data"                                      # data
    : "resource"                                  # otherwise resource
  )

  # Local reference to appid id
  appid_instance_id = (
    local.create_bastion_host == false
    ? null
    : local.create_appid == "data"
    ? data.ibm_resource_instance.appid[0].id
    : ibm_resource_instance.appid[0].id
  )

  # Local reference to appid guid
  appid_instance_guid = (
    local.create_bastion_host == false
    ? null
    : local.create_appid == "data"
    ? data.ibm_resource_instance.appid[0].guid
    : ibm_resource_instance.appid[0].guid
  )

  # List of teleport VSI
  teleport_vsi_list = module.dynamic_values.appid_redirect_urls
}

##############################################################################


##############################################################################
# Create App ID Used by Teleport Bastion VSI
##############################################################################

resource "ibm_resource_instance" "appid" {
  count             = local.create_appid == "resource" ? 1 : 0
  name              = "${var.prefix}-${var.appid.name}"
  service           = "appid"
  plan              = "graduated-tier"
  location          = var.region
  resource_group_id = local.resource_groups[var.appid.resource_group]
  tags              = var.tags
}

##############################################################################


##############################################################################
# Existing App ID used by Teleport Bastion VSI
##############################################################################

data "ibm_resource_instance" "appid" {
  count             = local.create_appid == "data" ? 1 : 0
  name              = var.appid.name
  resource_group_id = local.resource_groups[var.appid.resource_group]
}

##############################################################################


##############################################################################
# App ID Instance Keys
##############################################################################

resource "ibm_resource_key" "appid_key" {
  for_each = var.appid.keys == null || local.create_bastion_host == false ? {} : {
    for appid_key in var.appid.keys :
    (appid_key) => appid_key
  }
  name                 = "${var.prefix}-${each.key}-app-id-key"
  resource_instance_id = local.appid_instance_id
  role                 = "Writer"
  tags                 = var.tags
}

##############################################################################


##############################################################################
# App ID Redirect Url
##############################################################################

resource "ibm_appid_redirect_urls" "urls" {
  count     = local.create_bastion_host == true ? 1 : 0
  tenant_id = local.appid_instance_guid
  urls      = local.teleport_vsi_list
}

##############################################################################
