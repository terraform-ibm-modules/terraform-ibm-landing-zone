##############################################################################
# F5 VSI and Template Data
##############################################################################

module "f5" {
  source           = "./config_modules/f5"
  prefix           = var.prefix
  f5_vsi           = var.f5_vsi
  vpc_modules      = var.vpc_modules
  f5_template_data = var.f5_template_data
  region           = var.region
}

##############################################################################

##############################################################################
# F5 Cloud Init Data
##############################################################################

module "f5_cloud_init" {
  for_each                = module.f5.f5_vsi_map
  source                  = "../f5_config"
  region                  = var.region
  vpc_id                  = each.value.vpc_id
  zone                    = each.value.zone
  secondary_subnets       = each.value.secondary_subnets
  hostname                = each.value.hostname
  domain                  = each.value.domain
  tmos_admin_password     = lookup(var.f5_template_data, "tmos_admin_password", null) == null ? "null" : lookup(var.f5_template_data, "tmos_admin_password", null)
  license_type            = lookup(var.f5_template_data, "license_type", null) == null ? "null" : lookup(var.f5_template_data, "license_type", null)
  byol_license_basekey    = lookup(var.f5_template_data, "byol_license_basekey", null) == null ? "null" : lookup(var.f5_template_data, "byol_license_basekey", null)
  license_host            = lookup(var.f5_template_data, "license_host", null) == null ? "null" : lookup(var.f5_template_data, "license_host", null)
  license_username        = lookup(var.f5_template_data, "license_username", null) == null ? "null" : lookup(var.f5_template_data, "license_username", null)
  license_password        = lookup(var.f5_template_data, "license_password", null) == null ? "null" : lookup(var.f5_template_data, "license_password", null)
  license_pool            = lookup(var.f5_template_data, "license_pool", null) == null ? "null" : lookup(var.f5_template_data, "license_pool", null)
  license_sku_keyword_1   = lookup(var.f5_template_data, "license_sku_keyword_1", null) == null ? "null" : lookup(var.f5_template_data, "license_sku_keyword_1", null)
  license_sku_keyword_2   = lookup(var.f5_template_data, "license_sku_keyword_2", null) == null ? "null" : lookup(var.f5_template_data, "license_sku_keyword_2", null)
  license_unit_of_measure = lookup(var.f5_template_data, "license_unit_of_measure", null) == null ? "null" : lookup(var.f5_template_data, "license_unit_of_measure", null)
  do_declaration_url      = lookup(var.f5_template_data, "do_declaration_url", null) == null ? "null" : lookup(var.f5_template_data, "do_declaration_url", null)
  as3_declaration_url     = lookup(var.f5_template_data, "as3_declaration_url", null) == null ? "null" : lookup(var.f5_template_data, "as3_declaration_url", null)
  ts_declaration_url      = lookup(var.f5_template_data, "ts_declaration_url", null) == null ? "null" : lookup(var.f5_template_data, "ts_declaration_url", null)
  phone_home_url          = lookup(var.f5_template_data, "phone_home_url", null) == null ? "null" : lookup(var.f5_template_data, "phone_home_url", null)
  template_source         = lookup(var.f5_template_data, "template_source", null) == null ? "null" : lookup(var.f5_template_data, "template_source", null)
  template_version        = lookup(var.f5_template_data, "template_version", null) == null ? "null" : lookup(var.f5_template_data, "template_version", null)
  app_id                  = lookup(var.f5_template_data, "app_id", null) == null ? "null" : lookup(var.f5_template_data, "app_id", null)
  tgactive_url            = lookup(var.f5_template_data, "tgactive_url", null) == null ? "null" : lookup(var.f5_template_data, "tgactive_url", null)
  tgstandby_url           = lookup(var.f5_template_data, "tgstandby_url", null) == null ? "null" : lookup(var.f5_template_data, "tgstandby_url", null)
  tgrefresh_url           = lookup(var.f5_template_data, "tgrefresh_url", null) == null ? "null" : lookup(var.f5_template_data, "tgrefresh_url", null)
}


##############################################################################

##############################################################################
# [Unit Test] F5 and Template
##############################################################################

module "ut_f5" {
  source = "./config_modules/f5"
  prefix = "ut"
  region = "us-south"
  f5_vsi = [
    {
      name                = "f5-zone-1"
      primary_subnet_name = "subnet-1"
      vpc_name            = "test"
      secondary_subnet_names = [
        "subnet-f5-1",
        "subnet-f5-2"
      ]
      hostname = "f5-ve-01"
      domain   = "local"
    }
  ]
  vpc_modules = {
    test = {
      vpc_id = "1234"
      subnet_zone_list = [
        {
          name = "ut-test-subnet-1"
          id   = "1-id"
          zone = "1-zone"
          cidr = "10.10.10.10/10"
        },
        {
          name = "ut-test-subnet-f5-1"
          id   = "1-id"
          zone = "1-zone"
          cidr = "10.10.10.10/10"
        },
        {
          name = "ut-test-subnet-f5-2"
          id   = "1-id"
          zone = "1-zone"
          cidr = "10.10.10.10/10"
        }
      ]
    }
  }
  f5_template_data = {
    tmos_admin_password     = "Gooooooooooooooooodpass1"
    license_type            = "none"
    byol_license_basekey    = null
    license_host            = null
    license_username        = null
    license_password        = null
    license_pool            = null
    license_sku_keyword_1   = null
    license_sku_keyword_2   = null
    license_unit_of_measure = "hourly"
    do_declaration_url      = null
    as3_declaration_url     = null
    ts_declaration_url      = null
    phone_home_url          = null
    template_source         = "f5devcentral/ibmcloud_schematics_bigip_multinic_declared"
    template_version        = "20210201"
    app_id                  = null
    tgactive_url            = ""
    tgstandby_url           = null
    tgrefresh_url           = null
  }
}

locals {
  ut_f5_vsi_has_correct_zone     = regex("1-zone", module.ut_f5.f5_vsi_map["ut-f5-zone-1"].zone)
  ut_f5_assert_template_rendered = lookup(module.ut_f5.f5_template_map, "ut-f5-zone-1")
  ut_f5_template_regex           = regex("#cloud-config\nchpasswd:\n  expire: false\n  list: |\n    admin:frog\ntmos_dhcpv4_tmm:\n  enabled: true\n  rd_enabled: false\n  icontrollx_trusted_sources: false\n  inject_routes: true\n  configsync_interface: 1.1\n  default_route_interface: 1.2\n  dhcp_timeout: 120\n  dhcpv4_options:\n    mgmt:\n      host-name: f5-ve-01\n      domain-name: f5-ve-01\n    '1.2':\n      routers: 10.0.0.1\n  do_enabled: true \n  do_declaration: null\n  do_declaration_url: null\n  do_declaration_url_headers:\n    PRIVATE-TOKEN: x6VpQuWhiT_KgT3mzyTe\n  do_template_variables:\n    primary_dns: 8.8.8.8\n    secondary_dns: 1.1.1.1\n    timezone: Europe/Paris\n    primary_ntp: 132.163.96.5\n    secondary_ntp: 132.163.97.5\n    primary_radius: 10.20.22.20\n    primary_radius_secret: testing123\n    secondary_radius: 10.20.23.20\n    secondary_radius_secret: testing123\n  as3_enabled: true\n  as3_declaration_url: null\n  as3_declaration_url_headers:\n    PRIVATE-TOKEN: x6VpQuWhiT_KgT3mzyTe\n  as3_template_variables:\n    selfip_snat_address: 10.20.40.40\n  ts_enabled: true\n  ts_declaration_url: null\n  ts_declaration_url_headers:\n    PRIVATE-TOKEN: x6VpQuWhiT_KgT3mzyTe\n  ts_template_variables:\n    splunk_log_ingest: 10.20.23.30\n    splunk_password: 0f29e5dc-bee8-4898-9054-9b66574a3e14\n  phone_home_url: null\n  phone_home_url_verify_tls: false\n  phone_home_url_metadata:\n    template_source: f5devcentral/ibmcloud_schematics_bigip_multinic_declared\n    template_version: 20210201\n    zone: 1-zone\n    vpc: 1234\n    app_id: null\n  tgactive_url: \n  tgstandby_url: null\n  tgrefresh_url: null\n  ", module.ut_f5.f5_template_map["ut-f5-zone-1"].user_data)
}

##############################################################################