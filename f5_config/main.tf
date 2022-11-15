##############################################################################
# Template Data
##############################################################################

locals {
  do_byol_license      = <<EOD
    schemaVersion: 1.0.0
    class: Device
    async: true
    label: Cloudinit Onboarding
    Common:
      class: Tenant
      byoLicense:
        class: License
        licenseType: regKey
        regKey: ${var.byol_license_basekey}
EOD
  do_regekypool        = <<EOD
    schemaVersion: 1.0.0
    class: Device
    async: true
    label: Cloudinit Onboarding
    Common:
      class: Tenant
      poolLicense:
        class: License
        licenseType: licensePool
        bigIqHost: ${var.license_host}
        bigIqUsername: ${var.license_username}
        bigIqPassword: ${var.license_password}
        licensePool: ${var.license_pool}
        reachable: false
        hypervisor: kvm
EOD
  do_utilitypool       = <<EOD
    schemaVersion: 1.0.0
    class: Device
    async: true
    label: Cloudinit Onboarding
    Common:
      class: Tenant
      utilityLicense:
        class: License
        licenseType: licensePool
        bigIqHost: ${var.license_host}
        bigIqUsername: ${var.license_username}
        bigIqPassword: ${var.license_password}
        licensePool: ${var.license_pool}
        skuKeyword1: ${var.license_sku_keyword_1}
        skuKeyword2: ${var.license_sku_keyword_2}
        unitOfMeasure: ${var.license_unit_of_measure}
        reachable: false
        hypervisor: kvm
EOD
  do_dec1              = var.license_type == "byol" ? chomp(local.do_byol_license) : "null"
  do_dec2              = var.license_type == "regkeypool" ? chomp(local.do_regekypool) : local.do_dec1
  do_local_declaration = var.license_type == "utilitypool" ? chomp(local.do_utilitypool) : local.do_dec2
  user_data = templatefile("${path.module}/user_data.yaml",
    {
      tmos_admin_password     = var.tmos_admin_password,
      configsync_interface    = "1.1",
      hostname                = var.hostname,
      domain                  = var.domain,
      default_route_interface = var.default_route_interface == null ? "1.${length(var.secondary_subnets)}" : var.default_route_interface,
      default_route_gateway   = cidrhost(var.secondary_subnets[length(var.secondary_subnets) - 1].cidr, 1),
      do_local_declaration    = local.do_local_declaration,
      do_declaration_url      = var.do_declaration_url,
      as3_declaration_url     = var.as3_declaration_url,
      ts_declaration_url      = var.ts_declaration_url,
      phone_home_url          = var.phone_home_url,
      tgactive_url            = var.tgactive_url,
      tgstandby_url           = var.tgstandby_url,
      tgrefresh_url           = var.tgrefresh_url,
      template_source         = var.template_source,
      template_version        = var.template_version,
      zone                    = var.zone,
      vpc                     = var.vpc_id,
      app_id                  = var.app_id
  })
}


##############################################################################
