##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
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
  description = "Public SSH Key for VSI creation. Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
  validation {
    error_message = "Public SSH Key must be a valid ssh rsa public key."
    condition     = can(regex("ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3} ?([^@]+@[^@]+)?", var.ssh_public_key))
  }
}

variable "tags" {
  description = "List of tags to apply to resources created by this module."
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
  description = "Optionally, you can bring you own Hyper Protect Crypto Service instance for key management. If you would like to use that instance, add the name here. Otherwise, leave as null"
  type        = string
  default     = null
}

variable "hs_crypto_resource_group" {
  description = "If you're using Hyper Protect Crypto services in a resource group other than `Default`, provide the name here."
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
  default     = "ibm-ubuntu-18-04-6-minimal-amd64-2"
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
  description = "Image name for f5 deployments. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`]."
  type        = string
  default     = "f5-bigip-16-1-2-2-0-0-28-all-1slot"

  validation {
    error_message = "Invalid F5 image name. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`]."
    condition     = var.f5_image_name == null ? true : contains(["f5-bigip-15-1-5-1-0-0-14-all-1slot", "f5-bigip-15-1-5-1-0-0-14-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-ltm-1slot", "f5-bigip-16-1-2-2-0-0-28-all-1slot"], var.f5_image_name)
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
  default     = "ibm-ubuntu-18-04-6-minimal-amd64-2"
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
# Secrets Manager Variables
##############################################################################

variable "create_secrets_manager" {
  description = "Create a secrets manager deployment."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# Security and Compliance Center
##############################################################################

variable "enable_scc" {
  description = "Enable creation of SCC resources"
  type        = bool
  default     = false
}

variable "scc_cred_name" {
  description = "The name of the credential"
  type        = string
  default     = "slz-cred"

  validation {
    error_message = "SCC Credential Name must be 255 or fewer characters."
    condition     = var.scc_cred_name == null ? true : can(regex("^[a-zA-Z0-9-\\.\\*,_\\s]*$", var.scc_cred_name)) && length(var.scc_cred_name) <= 255
  }
}

variable "scc_group_id" {
  description = "Group ID of SCC Credential"
  type        = string
  default     = null

  validation {
    error_message = "SCC Credential Group ID must only contain numbers. Group ID must be 50 or fewer characters."
    condition     = var.scc_group_id == null ? true : can(regex("^[0-9]*$", var.scc_group_id)) && length(var.scc_group_id) <= 50
  }
}

variable "scc_group_passphrase" {
  description = "Group Passphrase of SCC Credential"
  type        = string
  sensitive   = true
  default     = null

  validation {
    error_message = "SCC Credential Group passphrase must be 255 or fewer characters."
    condition     = var.scc_group_passphrase == null ? true : can(regex("^[a-zA-Z0-9-\\.\\*,_\\s]*$", var.scc_group_passphrase)) && length(var.scc_group_passphrase) <= 255
  }
}

variable "scc_cred_description" {
  description = "Description of SCC Credential"
  type        = string
  default     = "This credential is used for SCC."

  validation {
    error_message = "SCC Credential Description must be 255 or fewer characters."
    condition     = var.scc_cred_description == null ? true : can(regex("^[a-zA-Z0-9-\\._,\\s]*$", var.scc_cred_description)) && length(var.scc_cred_description) <= 255
  }
}

variable "scc_collector_description" {
  description = "Description of SCC Collector"
  type        = string
  default     = "collector description"
  validation {
    error_message = "SCC Collector Description must be 1000 or fewer characters."
    condition     = var.scc_collector_description == null ? true : can(regex("^[a-zA-Z0-9-\\._,\\s]*$", var.scc_collector_description)) && length(var.scc_collector_description) <= 1000
  }
}

variable "scc_scope_description" {
  description = "Description of SCC Scope"
  type        = string
  default     = "IBM-schema-for-configuration-collection"
  validation {
    error_message = "SCC Scope Description must be 255 or fewer characters."
    condition     = var.scc_scope_description == null ? true : can(regex("^[a-zA-Z0-9-\\._,\\s]*$", var.scc_scope_description)) && length(var.scc_scope_description) <= 255
  }
}

variable "scc_scope_name" {
  description = "The name of the SCC Scope"
  type        = string
  default     = "scope"

  validation {
    error_message = "SCC Scope Name must be 50 or fewer characters."
    condition     = var.scc_scope_name == null ? true : can(regex("^[a-zA-Z0-9-\\.,_\\s]*$", var.scc_scope_name)) && length(var.scc_scope_name) <= 50
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
  description = "Override default values with custom JSON. Any value here other than an empty string will override all other configuration changes."
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
