##############################################################################
# Create Pattern Dynamic Variables
# > Values are created inside the `dynamic_modules/` module to allow them to
#   be tested
##############################################################################

module "dynamic_values" {
  source                              = "../../dynamic_values"
  prefix                              = var.prefix
  region                              = var.region
  vpcs                                = var.vpcs
  hs_crypto_instance_name             = var.hs_crypto_instance_name
  hs_crypto_resource_group            = var.hs_crypto_resource_group
  existing_kms_instance_name          = var.existing_kms_instance_name
  existing_kms_resource_group         = var.existing_kms_resource_group
  existing_kms_endpoint_type          = var.existing_kms_endpoint_type
  existing_cos_instance_name          = var.existing_cos_instance_name
  existing_cos_resource_group         = var.existing_cos_resource_group
  existing_cos_endpoint_type          = var.existing_cos_endpoint_type
  use_existing_cos_for_atracker       = var.use_existing_cos_for_atracker
  use_existing_cos_for_vpc_flowlogs   = var.use_existing_cos_for_vpc_flowlogs
  add_edge_vpc                        = var.add_edge_vpc
  create_f5_network_on_management_vpc = var.create_f5_network_on_management_vpc
  provision_teleport_in_f5            = var.provision_teleport_in_f5
  vpn_firewall_type                   = var.vpn_firewall_type
  f5_image_name                       = var.f5_image_name
  f5_instance_profile                 = var.f5_instance_profile
  app_id                              = var.app_id
  enable_f5_management_fip            = var.enable_f5_management_fip
  enable_f5_external_fip              = var.enable_f5_external_fip
  teleport_management_zones           = var.teleport_management_zones
  appid_resource_group                = var.appid_resource_group
  teleport_instance_profile           = var.teleport_instance_profile
  teleport_vsi_image_name             = var.teleport_vsi_image_name
  domain                              = var.domain
  hostname                            = var.hostname
  use_random_cos_suffix               = var.use_random_cos_suffix
  add_vsi_volume_encryption_key = (
    var.add_edge_vpc == true || var.teleport_management_zones > 0 || var.create_f5_network_on_management_vpc == true
    ? true
    : false
  )
  add_atracker_route = var.add_atracker_route
}

##############################################################################


##############################################################################
# Dynamically Create Default Configuration
##############################################################################

locals {
  # If override is true, parse the JSON from override.json otherwise parse empty string
  # Default override.json location can be replaced by using var.override_json_path
  # Empty string is used to avoid type conflicts with unary operators
  override = {
    override = jsondecode(var.override && var.override_json_string == "" ?
      (var.override_json_path == "" ? file("${path.root}/override.json") : file(var.override_json_path))
      :
    "{}")
    override_json_string = jsondecode(var.override_json_string == "" ? "{}" : var.override_json_string)
  }
  override_type = var.override_json_string == "" ? "override" : "override_json_string"


  ##############################################################################
  # Dynamic configuration for landing zone environment
  ##############################################################################

  config = {

    ##############################################################################
    # Cluster Config
    ##############################################################################
    clusters = [
      # Dynamically create identical cluster in each VPC
      for network in var.vpcs :
      {
        name     = "${network}-cluster"
        vpc_name = network
        subnet_names = [
          # For the number of zones in zones variable, get that many subnet names
          for zone in range(1, var.cluster_zones + 1) :
          "vsi-zone-${zone}"
        ]
        kms_config = {
          crk_name         = "${var.prefix}-roks-key"
          private_endpoint = true
        }
        workers_per_subnet                  = var.workers_per_zone
        machine_type                        = var.flavor
        kube_type                           = "openshift"
        kube_version                        = var.kube_version
        resource_group                      = "${var.prefix}-${network}-rg"
        cos_name                            = "cos"
        entitlement                         = var.entitlement
        secondary_storage                   = var.secondary_storage
        addons                              = var.cluster_addons
        manage_all_addons                   = var.manage_all_cluster_addons
        boot_volume_crk_name                = "${var.prefix}-roks-key"
        disable_outbound_traffic_protection = var.disable_outbound_traffic_protection
        cluster_force_delete_storage        = var.cluster_force_delete_storage
        operating_system                    = var.operating_system
        kms_wait_for_apply                  = var.kms_wait_for_apply
        use_private_endpoint                = var.use_private_endpoint
        verify_worker_network_readiness     = var.verify_worker_network_readiness
        ignore_worker_pool_size_changes     = var.ignore_worker_pool_size_changes
        cluster_config_endpoint_type        = var.cluster_config_endpoint_type
        # By default, create dedicated pool for logging
        worker_pools = [
          # {
          #   name     = "logging-worker-pool"
          #   vpc_name = network
          #   subnet_names = [
          #     for zone in range(1, var.cluster_zones + 1) :
          #     "vsi-zone-${zone}"
          #   ]
          #   entitlement          = var.entitlement
          #   workers_per_subnet   = var.workers_per_zone
          #   flavor               = var.flavor
          #   boot_volume_crk_name = "${var.prefix}-roks-key"
          # }
        ]
      }
    ]
    ##############################################################################

    ##############################################################################
    # Default SSH key
    ##############################################################################
    ssh_keys = var.ssh_public_key != null || var.existing_ssh_key_name != null ? [
      {
        name       = var.ssh_public_key != null ? "ssh-key" : var.existing_ssh_key_name
        public_key = var.existing_ssh_key_name == null ? var.ssh_public_key : null
      }
    ] : []

    ##############################################################################

    ##############################################################################
    # VPE
    ##############################################################################
    virtual_private_endpoints = [{
      service_name   = "cos"
      service_type   = "cloud-object-storage"
      resource_group = "${var.prefix}-service-rg"
      vpcs = [
        # Create VPE for each VPC in VPE tier
        for network in module.dynamic_values.vpc_list :
        {
          name                = network
          subnets             = ["vpe-zone-1", "vpe-zone-2", "vpe-zone-3"]
          security_group_name = "${network}-vpe-sg"
        }
      ]
    }]
    ##############################################################################

    ##############################################################################
    # Deployment Configuration From Dynamic Values
    ##############################################################################

    resource_groups                = module.dynamic_values.resource_groups
    vpcs                           = module.dynamic_values.vpcs
    enable_transit_gateway         = var.enable_transit_gateway
    transit_gateway_global         = var.transit_gateway_global
    transit_gateway_resource_group = "${var.prefix}-service-rg"
    transit_gateway_connections    = module.dynamic_values.vpc_list
    object_storage                 = module.dynamic_values.object_storage
    key_management                 = module.dynamic_values.key_management
    vpn_gateways                   = module.dynamic_values.vpn_gateways
    f5_deployments                 = module.dynamic_values.f5_deployments
    security_groups                = module.dynamic_values.security_groups
    vsi                            = []
    atracker                       = module.dynamic_values.atracker

    ##############################################################################

    ##############################################################################
    # S2S Authorization
    ##############################################################################
    skip_kms_block_storage_s2s_auth_policy = var.skip_kms_block_storage_s2s_auth_policy
    skip_all_s2s_auth_policies             = var.skip_all_s2s_auth_policies

    ##############################################################################

    ##############################################################################
    # Appid config
    ##############################################################################

    appid = {
      name           = var.appid_name
      use_data       = var.use_existing_appid
      resource_group = var.appid_resource_group == null ? "${var.prefix}-service-rg" : var.appid_resource_group
      use_appid      = var.teleport_management_zones > 0 || var.provision_teleport_in_f5
      keys           = ["slz-appid-key"]
    }

    ##############################################################################

    ##############################################################################
    # Teleport Config Data
    ##############################################################################

    teleport_config = {
      teleport_license   = var.teleport_license
      https_cert         = var.https_cert
      https_key          = var.https_key
      domain             = var.teleport_domain
      cos_bucket_name    = "bastion-bucket"
      cos_key_name       = "bastion-key"
      teleport_version   = var.teleport_version
      message_of_the_day = var.message_of_the_day
      app_id_key_name    = "slz-appid-key"
      hostname           = var.teleport_hostname
      claims_to_roles = [
        {
          email = var.teleport_admin_email
          roles = ["teleport-admin"]
        }
      ]
    }

    teleport_vsi = module.dynamic_values.teleport_vsi

    ##############################################################################
  }

  ##############################################################################
  # Compile Environment for Config output
  ##############################################################################
  env = {
    resource_groups                        = lookup(local.override[local.override_type], "resource_groups", local.config.resource_groups)
    vpcs                                   = lookup(local.override[local.override_type], "vpcs", local.config.vpcs)
    vpn_gateways                           = lookup(local.override[local.override_type], "vpn_gateways", local.config.vpn_gateways)
    enable_transit_gateway                 = lookup(local.override[local.override_type], "enable_transit_gateway", local.config.enable_transit_gateway)
    transit_gateway_global                 = lookup(local.override[local.override_type], "transit_gateway_global", local.config.transit_gateway_global)
    transit_gateway_resource_group         = lookup(local.override[local.override_type], "transit_gateway_resource_group", local.config.transit_gateway_resource_group)
    transit_gateway_connections            = lookup(local.override[local.override_type], "transit_gateway_connections", local.config.transit_gateway_connections)
    ssh_keys                               = lookup(local.override[local.override_type], "ssh_keys", local.config.ssh_keys)
    network_cidr                           = lookup(local.override[local.override_type], "network_cidr", var.network_cidr)
    vsi                                    = lookup(local.override[local.override_type], "vsi", local.config.vsi)
    security_groups                        = lookup(local.override[local.override_type], "security_groups", local.config.security_groups)
    virtual_private_endpoints              = lookup(local.override[local.override_type], "virtual_private_endpoints", local.config.virtual_private_endpoints)
    cos                                    = lookup(local.override[local.override_type], "cos", local.config.object_storage)
    service_endpoints                      = lookup(local.override[local.override_type], "service_endpoints", var.service_endpoints)
    skip_kms_block_storage_s2s_auth_policy = lookup(local.override[local.override_type], "skip_kms_block_storage_s2s_auth_policy", local.config.skip_kms_block_storage_s2s_auth_policy)
    skip_all_s2s_auth_policies             = lookup(local.override[local.override_type], "skip_all_s2s_auth_policies", local.config.skip_all_s2s_auth_policies)
    key_management                         = lookup(local.override[local.override_type], "key_management", local.config.key_management)
    atracker                               = lookup(local.override[local.override_type], "atracker", local.config.atracker)
    clusters                               = lookup(local.override[local.override_type], "clusters", local.config.clusters)
    wait_till                              = lookup(local.override[local.override_type], "wait_till", var.wait_till)
    appid                                  = lookup(local.override[local.override_type], "appid", local.config.appid)
    f5_vsi                                 = lookup(local.override[local.override_type], "f5_vsi", local.config.f5_deployments)
    f5_template_data = {
      tmos_admin_password     = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.tmos_admin_password : lookup(local.override[local.override_type].f5_template_data, "tmos_admin_password", var.tmos_admin_password)
      license_type            = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_type : lookup(local.override[local.override_type].f5_template_data, "license_type", var.license_type)
      byol_license_basekey    = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.byol_license_basekey : lookup(local.override[local.override_type].f5_template_data, "byol_license_basekey", var.byol_license_basekey)
      license_host            = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_host : lookup(local.override[local.override_type].f5_template_data, "license_host", var.license_host)
      license_username        = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_username : lookup(local.override[local.override_type].f5_template_data, "license_username", var.license_username)
      license_password        = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_password : lookup(local.override[local.override_type].f5_template_data, "license_password", var.license_password)
      license_pool            = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_pool : lookup(local.override[local.override_type].f5_template_data, "license_pool", var.license_pool)
      license_sku_keyword_1   = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_sku_keyword_1 : lookup(local.override[local.override_type].f5_template_data, "license_sku_keyword_1", var.license_sku_keyword_1)
      license_sku_keyword_2   = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_sku_keyword_2 : lookup(local.override[local.override_type].f5_template_data, "license_sku_keyword_2", var.license_sku_keyword_2)
      license_unit_of_measure = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.license_unit_of_measure : lookup(local.override[local.override_type].f5_template_data, "license_unit_of_measure", var.license_unit_of_measure)
      do_declaration_url      = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.do_declaration_url : lookup(local.override[local.override_type].f5_template_data, "do_declaration_url", var.do_declaration_url)
      as3_declaration_url     = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.as3_declaration_url : lookup(local.override[local.override_type].f5_template_data, "as3_declaration_url", var.as3_declaration_url)
      ts_declaration_url      = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.ts_declaration_url : lookup(local.override[local.override_type].f5_template_data, "ts_declaration_url", var.ts_declaration_url)
      phone_home_url          = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.phone_home_url : lookup(local.override[local.override_type].f5_template_data, "phone_home_url", var.phone_home_url)
      template_source         = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.template_source : lookup(local.override[local.override_type].f5_template_data, "template_source", var.template_source)
      template_version        = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.template_version : lookup(local.override[local.override_type].f5_template_data, "template_version", var.template_version)
      app_id                  = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.app_id : lookup(local.override[local.override_type].f5_template_data, "app_id", var.app_id)
      tgactive_url            = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.tgactive_url : lookup(local.override[local.override_type].f5_template_data, "tgactive_url", var.tgactive_url)
      tgstandby_url           = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.tgstandby_url : lookup(local.override[local.override_type].f5_template_data, "tgstandby_url", var.tgstandby_url)
      tgrefresh_url           = lookup(local.override[local.override_type], "f5_template_data", null) == null ? var.tgrefresh_url : lookup(local.override[local.override_type].f5_template_data, "tgrefresh_url", var.tgrefresh_url)
    }
    teleport_vsi = lookup(local.override[local.override_type], "teleport_vsi", local.config.teleport_vsi)
    teleport_config = {
      teleport_license   = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.teleport_license : lookup(local.override[local.override_type].teleport_config, "teleport_license", local.config.teleport_config.teleport_license)
      https_cert         = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.https_cert : lookup(local.override[local.override_type].teleport_config, "https_cert", local.config.teleport_config.https_cert)
      https_key          = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.https_key : lookup(local.override[local.override_type].teleport_config, "https_key", local.config.teleport_config.https_key)
      domain             = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.domain : lookup(local.override[local.override_type].teleport_config, "domain", local.config.teleport_config.domain)
      cos_bucket_name    = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.cos_bucket_name : lookup(local.override[local.override_type].teleport_config, "cos_bucket_name", local.config.teleport_config.cos_bucket_name)
      cos_key_name       = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.cos_key_name : lookup(local.override[local.override_type].teleport_config, "cos_key_name", local.config.teleport_config.cos_key_name)
      teleport_version   = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.teleport_version : lookup(local.override[local.override_type].teleport_config, "teleport_version", local.config.teleport_config.teleport_version)
      message_of_the_day = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.message_of_the_day : lookup(local.override[local.override_type].teleport_config, "message_of_the_day", local.config.teleport_config.message_of_the_day)
      app_id_key_name    = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.app_id_key_name : lookup(local.override[local.override_type].teleport_config, "app_id_key_name", local.config.teleport_config.app_id_key_name)
      hostname           = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.hostname : lookup(local.override[local.override_type].teleport_config, "hostname", local.config.teleport_config.hostname)
      claims_to_roles    = lookup(local.override[local.override_type], "teleport_config", null) == null ? local.config.teleport_config.claims_to_roles : lookup(local.override[local.override_type].teleport_config, "claims_to_roles", local.config.teleport_config.claims_to_roles)
    }
    vpc_placement_groups = lookup(local.override[local.override_type], "vpc_placement_groups", [])

  }
  ##############################################################################

  string = "\"${jsonencode(local.env)}\""
}

##############################################################################

##############################################################################
# Convert Environment to escaped readable string
##############################################################################

data "external" "format_output" {
  program = ["python3", "${path.module}/scripts/output.py", local.string]
}

##############################################################################


##############################################################################
# Conflicting Variable Failure States
##############################################################################

locals {
  # Prevent users from inputting conflicting variables by checking regex
  # causing plan to fail when true.
  # > if both are false will pass
  # > if only one is true will pass
  # tflint-ignore: terraform_unused_declarations
  fail_with_conflicting_bastion = regex("false", tostring(
    var.add_edge_vpc == false && var.create_f5_network_on_management_vpc == false
    ? false
    : var.add_edge_vpc == var.create_f5_network_on_management_vpc
  ))

  # Prevent users from provisioning bastion subnets without a tier selected
  # tflint-ignore: terraform_unused_declarations
  fail_with_no_vpn_firewall_type = regex("false", tostring(
    var.vpn_firewall_type == null && var.provision_teleport_in_f5
  ))

  # Prevent users from setting firewall type without f5
  # tflint-ignore: terraform_unused_declarations
  fail_with_no_f5_and_vpn_firewall_type = regex("false", tostring(
  var.vpn_firewall_type != null && (var.add_edge_vpc == false && var.create_f5_network_on_management_vpc == false)))

  # Prevent users from provisioning using both external and management fip
  # VSI can only have one floating IP per device
  # tflint-ignore: terraform_unused_declarations
  fail_with_both_f5_fip = regex("false", tostring(
    var.enable_f5_management_fip == true && var.enable_f5_external_fip == true
  ))

  # Prevent users from provisioning bastion on edge and management
  # tflint-ignore: terraform_unused_declarations
  fail_with_both_bastion_host_types = regex("false", tostring(
    var.provision_teleport_in_f5 && var.teleport_management_zones > 0
  ))

}

##############################################################################
