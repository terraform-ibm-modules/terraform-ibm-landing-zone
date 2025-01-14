##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources that is prepended to resources that are provisioned. Must begin with a lowercase letter and end with a lowercase letter or number. Must be 16 or fewer characters."
  type        = string
  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
}

variable "ssh_public_key" {
  description = "A public SSH Key for VSI creation which does not already exist in the deployment region. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended) - See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys. To use an existing key, enter a value for the variable 'existing_ssh_key_name' instead."
  type        = string
  default     = null
  validation {
    error_message = "Public SSH Key must be a valid ssh rsa public key."
    condition     = var.ssh_public_key == null || can(regex("ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3} ?([^@]+@[^@]+)?", var.ssh_public_key))
  }
}

variable "existing_ssh_key_name" {
  description = "The name of a public SSH Key which already exists in the deployment region that will be used for VSI creation. To add a new SSH key, use the variable 'ssh_public_key' instead."
  type        = string
  default     = null
}

variable "tags" {
  description = "List of resource tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "network_cidr" {
  description = "Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning."
  type        = string
  default     = "10.0.0.0/8"
}

variable "vpcs" {
  description = "List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. VPC names must begin with a lowercase letter and end with a lowercase letter or number."
  type        = list(string)
  default     = ["management", "workload"]

  validation {
    error_message = "VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. Names must also begin with a lowercase letter and end with a lowercase letter or number."
    condition = length([
      for name in var.vpcs :
      name if length(name) > 16 || !can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", name))
    ]) == 0
  }
}

variable "enable_transit_gateway" {
  description = "Create transit gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_global" {
  description = "Connect to the networks outside the associated region. Will only be used if transit gateway is enabled."
  type        = bool
  default     = false
}

variable "add_atracker_route" {
  description = "Atracker can only have one route per zone. Use this value to disable or enable the creation of atracker route"
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Key Management Variables
##############################################################################

variable "hs_crypto_instance_name" {
  description = "Specify the name of the Hyper Protect Crypto Services instance for key management. Leave as null to use the Key Protect service."
  type        = string
  default     = null
}

variable "hs_crypto_resource_group" {
  description = "For Hyper Protect Crypto Services (HPCS), specify the name of the resource group for the instance in `hs_crypto_instance_name`. Leave as null for the `Default` resource group or if not using HPCS."
  type        = string
  default     = null
}

##############################################################################


##############################################################################
# COS Variables
##############################################################################

variable "use_random_cos_suffix" {
  description = "Add a random 8 character string to the end of each cos instance, bucket, and key."
  type        = bool
  default     = true
}

##############################################################################


##############################################################################
# Virtual Server Variables
##############################################################################

variable "vsi_image_name" {
  description = "VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images."
  type        = string
  default     = "ibm-ubuntu-24-04-6-minimal-amd64-2"
}

variable "vsi_instance_profile" {
  description = "VSI image profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
  default     = "cx2-4x8"
}

variable "vsi_per_subnet" {
  description = "Number of Virtual Servers to create on each VSI subnet."
  type        = number
  default     = 1
}

variable "use_legacy_network_interface" {
  description = "Set this to true to use legacy network interface for the created instances."
  type        = bool
  default     = false
}

##############################################################################


##############################################################################
# F5 Variables
##############################################################################

variable "add_edge_vpc" {
  description = "Create an edge VPC. This VPC will be dynamically added to the list of VPCs in `var.vpcs`. Conflicts with `create_f5_network_on_management_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
  default     = false
}

variable "create_f5_network_on_management_vpc" {
  description = "Set up bastion on management VPC. This value conflicts with `add_edge_vpc` to prevent overlapping subnet CIDR blocks."
  type        = bool
  default     = false
}

variable "provision_teleport_in_f5" {
  description = "Provision teleport VSI in `bastion` subnet tier of F5 network if able."
  type        = bool
  default     = false
}

variable "vpn_firewall_type" {
  description = "Bastion type if provisioning bastion. Can be `full-tunnel`, `waf`, or `vpn-and-waf`."
  type        = string
  default     = null

  validation {
    error_message = "Bastion type must be `full-tunnel`, `waf`, `vpn-and-waf` or `null`."
    condition = (
      # if bastion type is null
      var.vpn_firewall_type == null
      # return true
      ? true
      # otherwise check list
      : contains(["full-tunnel", "waf", "vpn-and-waf"], var.vpn_firewall_type)
    )
  }

}

variable "f5_image_name" {
  description = "Image name for f5 deployments. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`,`f5-bigip-16-1-3-2-0-0-4-ltm-1slot`,`f5-bigip-16-1-3-2-0-0-4-all-1slot`,`f5-bigip-17-0-0-1-0-0-4-ltm-1slot`,`f5-bigip-17-0-0-1-0-0-4-all-1slot`]."
  type        = string
  default     = "f5-bigip-17-0-0-1-0-0-4-all-1slot"

  validation {
    error_message = "Invalid F5 image name. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`,`f5-bigip-16-1-3-2-0-0-4-ltm-1slot`,`f5-bigip-16-1-3-2-0-0-4-all-1slot`,`f5-bigip-17-0-0-1-0-0-4-ltm-1slot`,`f5-bigip-17-0-0-1-0-0-4-all-1slot`]."
    condition     = var.f5_image_name == null ? true : contains(["f5-bigip-15-1-5-1-0-0-14-all-1slot", "f5-bigip-15-1-5-1-0-0-14-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-all-1slot", "f5-bigip-16-1-3-2-0-0-4-ltm-1slot", "f5-bigip-16-1-3-2-0-0-4-all-1slot", "f5-bigip-17-0-0-1-0-0-4-ltm-1slot", "f5-bigip-17-0-0-1-0-0-4-all-1slot"], var.f5_image_name)
  }
}

variable "f5_instance_profile" {
  description = "F5 vsi instance profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
  default     = "cx2-4x8"
}

variable "hostname" {
  description = "The F5 BIG-IP hostname"
  type        = string
  default     = "f5-ve-01"
}

variable "domain" {
  description = "The F5 BIG-IP domain name"
  type        = string
  default     = "local"
}

variable "tmos_admin_password" {
  description = "admin account password for the F5 BIG-IP instance"
  type        = string
  sensitive   = true
  default     = null

  validation {
    error_message = "Value for tmos_password must be at least 15 characters, contain one numeric, one uppercase, and one lowercase character."
    condition = var.tmos_admin_password == null ? true : (
      length(var.tmos_admin_password) >= 15
      && can(regex("[A-Z]", var.tmos_admin_password))
      && can(regex("[a-z]", var.tmos_admin_password))
      && can(regex("[0-9]", var.tmos_admin_password))
    )
  }
}

variable "license_type" {
  description = "How to license, may be 'none','byol','regkeypool','utilitypool'"
  type        = string
  default     = "none"

  validation {
    error_message = "License type may be one of 'none','byol','regkeypool','utilitypool'."
    condition     = contains(["none", "byol", "regkeypool", "utilitypool"], var.license_type)
  }
}

variable "byol_license_basekey" {
  description = "Bring your own license registration key for the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_host" {
  description = "BIGIQ IP or hostname to use for pool based licensing of the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_username" {
  description = "BIGIQ username to use for the pool based licensing of the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_password" {
  description = "BIGIQ password to use for the pool based licensing of the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_pool" {
  description = "BIGIQ license pool name of the pool based licensing of the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_sku_keyword_1" {
  description = "BIGIQ primary SKU for ELA utility licensing of the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_sku_keyword_2" {
  description = "BIGIQ secondary SKU for ELA utility licensing of the F5 BIG-IP instance"
  type        = string
  default     = null
}

variable "license_unit_of_measure" {
  description = "BIGIQ utility pool unit of measurement"
  type        = string
  default     = "hourly"
}

variable "do_declaration_url" {
  description = "URL to fetch the f5-declarative-onboarding declaration"
  type        = string
  default     = "null"
}

variable "as3_declaration_url" {
  description = "URL to fetch the f5-appsvcs-extension declaration"
  type        = string
  default     = "null"
}

variable "ts_declaration_url" {
  description = "URL to fetch the f5-telemetry-streaming declaration"
  type        = string
  default     = "null"
}

variable "phone_home_url" {
  description = "The URL to POST status when BIG-IP is finished onboarding"
  type        = string
  default     = "null"
}

variable "template_source" {
  description = "The terraform template source for phone_home_url_metadata"
  type        = string
  default     = "f5devcentral/ibmcloud_schematics_bigip_multinic_declared"
}

variable "template_version" {
  description = "The terraform template version for phone_home_url_metadata"
  type        = string
  default     = "20210201"
}

variable "app_id" {
  description = "The terraform application id for phone_home_url_metadata"
  type        = string
  default     = "null"
}

variable "tgactive_url" {
  type        = string
  description = "The URL to POST L3 addresses when tgactive is triggered"
  default     = ""
}

variable "tgstandby_url" {
  description = "The URL to POST L3 addresses when tgstandby is triggered"
  type        = string
  default     = "null"
}

variable "tgrefresh_url" {
  description = "The URL to POST L3 addresses when tgrefresh is triggered"
  type        = string
  default     = "null"
}

variable "enable_f5_management_fip" {
  description = "Enable F5 management interface floating IP. Conflicts with `enable_f5_external_fip`, VSI can only have one floating IP per instance."
  type        = bool
  default     = false
}

variable "enable_f5_external_fip" {
  description = "Enable F5 external interface floating IP. Conflicts with `enable_f5_management_fip`, VSI can only have one floating IP per instance."
  type        = bool
  default     = false
}


##############################################################################


##############################################################################
# Teleport VSI Variables
##############################################################################

variable "teleport_management_zones" {
  description = "Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value."
  type        = number
  default     = 0

  validation {
    error_message = "Teleport Management Zones can only be 0, 1, 2, or 3."
    condition     = var.teleport_management_zones >= 0 && var.teleport_management_zones < 4
  }
}

variable "use_existing_appid" {
  description = "Use an existing appid instance. If this is false, one will be automatically created."
  type        = bool
  default     = false
}

variable "appid_name" {
  description = "Name of appid instance."
  type        = string
  default     = "appid"
}

variable "appid_resource_group" {
  description = "Resource group for existing appid instance. This value is ignored if a new instance is created."
  type        = string
  default     = null
}

variable "teleport_instance_profile" {
  description = "Machine type for Teleport VSI instances. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
  default     = "cx2-4x8"
}

variable "teleport_vsi_image_name" {
  description = "Teleport VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images."
  type        = string
  default     = "ibm-ubuntu-24-04-6-minimal-amd64-2"
}

variable "teleport_license" {
  description = "The contents of the PEM license file"
  type        = string
  default     = null
}

variable "https_cert" {
  description = "The https certificate used by bastion host for teleport"
  type        = string
  default     = null
}

variable "https_key" {
  description = "The https private key used by bastion host for teleport"
  type        = string
  default     = null
}
variable "teleport_hostname" {
  description = "The name of the instance or bastion host"
  type        = string
  default     = null
}

variable "teleport_domain" {
  description = "The domain of the bastion host"
  type        = string
  default     = null
}

variable "teleport_version" {
  description = "Version of Teleport Enterprise to use"
  type        = string
  default     = "7.1.0"
}

variable "message_of_the_day" {
  description = "Banner message that is exposed to the user at authentication time"
  type        = string
  default     = null
}

variable "teleport_admin_email" {
  description = "Email for teleport vsi admin."
  type        = string
  default     = null
}


##############################################################################

##############################################################################
# s2s variables
##############################################################################

variable "skip_kms_block_storage_s2s_auth_policy" {
  description = "Whether to skip the creation of a service-to-service authorization policy between block storage and the key management service."
  type        = bool
  default     = false
}

variable "skip_all_s2s_auth_policies" {
  description = "Whether to skip the creation of all of the service-to-service authorization policies. If setting to true, policies must be in place on the account before provisioning."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# KMS and App ID variables
##############################################################################
variable "service_endpoints" {
  description = "Service endpoints. Can be `public`, `private`, or `public-and-private`"
  type        = string
  default     = "public-and-private"

  validation {
    error_message = "Service endpoints can only be `public`, `private`, or `public-and-private`."
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
  }
}

##############################################################################

##############################################################################
# Override JSON
##############################################################################

variable "override" {
  description = "Override default values with custom JSON template. This uses the file `override.json` to allow users to create a fully customized environment."
  type        = bool
  default     = false
}

variable "override_json_string" {
  description = "Override default values with a JSON object. Any JSON other than an empty string overrides other configuration changes. You can use the [landing zone configuration tool](https://terraform-ibm-modules.github.io/landing-zone-config-tool/#/home) to create the JSON."
  type        = string
  default     = ""
}

variable "override_json_path" {
  description = "Override default values with custom `override.json` file. Specify the location of `override.json`. Any value here other than an empty string will override all other configuration changes. Note: if `var.override_json_string` is specified then this variable is ignored."
  type        = string
  default     = ""
}

##############################################################################

##############################################################################
# Schematics Output
##############################################################################

# tflint-ignore: terraform_naming_convention
variable "IC_SCHEMATICS_WORKSPACE_ID" {
  default     = ""
  type        = string
  description = "leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace"
}

##############################################################################

##############################################################################
# CBR variables
##############################################################################

variable "existing_vpc_cbr_zone_id" {
  type        = string
  description = "ID of the existing CBR (Context-based restrictions) network zone, with context set to the VPC. This zone is used in a CBR rule, which allows traffic to flow only from the landing zone VPCs to specific cloud services."
  default     = null
}

##############################################################################
