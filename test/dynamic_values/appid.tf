##############################################################################
# App ID Locals
##############################################################################

module "appid" {
  source          = "./config_modules/appid"
  prefix          = var.prefix
  teleport_domain = var.teleport_domain
  teleport_vsi    = var.bastion_vsi
}

##############################################################################

##############################################################################
# [Unit Test] Test correct redirect urls
##############################################################################

module "unit_test_appid" {
  source          = "./config_modules/appid"
  prefix          = "ut"
  teleport_domain = "domain.com"
  teleport_vsi = [
    {
      name = "test-vsi"
    }
  ]
}

locals {
  assert_appid_instance_contains_redirect_url = regex("https://ut-test-vsi.domain.com:3080/v1/webapi/oidc/callback", module.unit_test_appid.redirect_urls[0])
}

##############################################################################
