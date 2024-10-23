##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "A unique identifier for resources that is prepended to resources that are provisioned. Must begin with a lowercase letter and end with a lowercase letter or number. Must be 13 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin with a letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 13 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 13
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
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

variable "ignore_vpcs_for_cluster_deployment" {
  description = "List of VPCs from input `vpcs` that should be ignored when deploying OpenShift clusters. If empty then a cluster will be deployed in all VPCs specified in input `vpcs`."
  type        = list(string)
  default     = []
  nullable    = false
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
  description = "Atracker can only have one route per zone. use this value to disable or enable the creation of atracker route"
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

variable "existing_kms_instance_name" {
  description = "Specify the name of an existing Key Management Service instance for key management. Leave as null to deploy a new Key Protect service."
  type        = string
  default     = null
}

variable "existing_kms_resource_group" {
  description = "For using an existing Key Management Service (KMS), specify the name of the resource group for the instance in `existing_kms_instance_name`. Leave as null for the `Default` resource group or if not using an existing KMS."
  type        = string
  default     = null
}

variable "existing_kms_endpoint_type" {
  description = "The endpoint type to use when accessing the existing KMS instance, default is `public`."
  type        = string
  default     = "public"

  validation {
    error_message = "Endpoint type can only be `public` or `private`."
    condition     = contains(["public", "private", null], var.existing_kms_endpoint_type)
  }
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

variable "existing_cos_instance_name" {
  description = "Specify the name of an existing Cloud Object Storage (COS) instance that can be used for new buckets, if required."
  type        = string
  default     = null
}

variable "existing_cos_resource_group" {
  description = "For using an existing Cloud Object Storage (COS) instance, specify the name of the resource group for the instance in `existing_cos_instance_name`. Leave as null for the `Default` resource group or if not using an existing COS."
  type        = string
  default     = null
}

variable "existing_cos_endpoint_type" {
  description = "The endpoint type to use when accessing the existing COS instance, default is `public`."
  type        = string
  default     = "public"

  validation {
    error_message = "Endpoint type can only be `public` or `private`."
    condition     = contains(["public", "private", null], var.existing_cos_endpoint_type)
  }
}

variable "use_existing_cos_for_vpc_flowlogs" {
  description = "Set to `true` if you have chosen to include an `existing_cos_instance_name` and wish to use that instance for your VPC Flow Log bucket. This setting will only be used if an `existing_cos_instance_name` is supplied."
  type        = bool
  default     = false
  nullable    = false
}

variable "use_existing_cos_for_atracker" {
  description = "Set to `true` if you have chosen to include an `existing_cos_instance_name` and wish to use that instance for your Activity Tracker (atracker) routing. This setting will only be used if an `existing_cos_instance_name` is supplied."
  type        = bool
  default     = false
  nullable    = false
}

##############################################################################


##############################################################################
# Cluster Variables
##############################################################################

variable "cluster_zones" {
  description = "Number of zones to provision clusters for each VPC. At least one zone is required. Can be 1, 2, or 3 zones."
  type        = number
  default     = 3

  validation {
    error_message = "Cluster can be provisioned only across 1, 2, or 3 zones."
    condition     = var.cluster_zones > 0 && var.cluster_zones < 4
  }
}

variable "kube_version" {
  description = "The version of the OpenShift cluster that should be provisioned. Current supported values are '4.16_openshift', '4.15_openshift', '4.14_openshift', '4.13_openshift', or '4.12_openshift'. NOTE: This is only used during initial cluster provisioning, but ignored for future updates. Cluster version updates should be done outside of terraform to prevent possible destructive changes."
  type        = string
  default     = "4.16_openshift"
  validation {
    condition = anytrue([
      var.kube_version == null,
      var.kube_version == "default",
      var.kube_version == "4.16_openshift",
      var.kube_version == "4.15_openshift",
      var.kube_version == "4.14_openshift",
      var.kube_version == "4.13_openshift",
      var.kube_version == "4.12_openshift",
    ])
    error_message = "The kube_version value can currently only be '4.16_openshift', '4.15_openshift', '4.14_openshift', '4.13_openshift', or '4.12_openshift'"
  }
}

variable "flavor" {
  description = "Machine type for cluster. Use the IBM Cloud CLI command `ibmcloud ks flavors` to find valid machine types"
  type        = string
  default     = "bx2.16x64"
}

variable "workers_per_zone" {
  description = "Number of workers in each zone of the cluster. OpenShift requires at least 2 workers."
  type        = number
  default     = 1
}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
  type        = string
  default     = "IngressReady"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady"
    ], var.wait_till)
  }
}

variable "kms_wait_for_apply" {
  type        = bool
  description = "Set true to make terraform wait until KMS is applied to master and it is ready and deployed. Default value is true."
  default     = true
}

variable "entitlement" {
  description = "Reduces the cost of additional OCP in OpenShift clusters. If you do not have an entitlement, leave as null. Use Cloud Pak with OCP License entitlement to create the OpenShift cluster. Specify `cloud_pak` only if you use the cluster with a Cloud Pak that has an OpenShift entitlement. The value is set only when the cluster is created."
  type        = string
  default     = null
}

variable "secondary_storage" {
  description = "Optionally specify a secondary storage option to attach to all cluster worker nodes. This value is immutable and can't be changed after provisioning. Use the IBM Cloud CLI command ibmcloud ks flavors to find valid options, e.g ibmcloud ks flavor get --flavor bx2.16x64 --provider vpc-gen2 --zone us-south-1."
  type        = string
  default     = null
}

variable "cluster_addons" {
  type = object({
    debug-tool                = optional(string)
    image-key-synchronizer    = optional(string)
    openshift-data-foundation = optional(string)
    vpc-file-csi-driver       = optional(string)
    static-route              = optional(string)
    cluster-autoscaler        = optional(string)
    vpc-block-csi-driver      = optional(string)
  })
  description = "Map of OCP cluster add-on versions to install (NOTE: The 'vpc-block-csi-driver' add-on is installed by default for VPC clusters, however you can explicitly specify it here if you wish to choose a later version than the default one). For full list of all supported add-ons and versions, see https://cloud.ibm.com/docs/containers?topic=containers-supported-cluster-addon-versions"
  default     = null
}

variable "manage_all_cluster_addons" {
  type        = bool
  default     = false
  nullable    = false # null values are set to default value
  description = "Instructs Terraform to manage all cluster addons, even if addons were installed outside of the module. If set to 'true' this module will destroy any addons that were installed by other sources."
}

variable "disable_outbound_traffic_protection" {
  type        = bool
  description = "Whether to allow public outbound access from the cluster workers. This is only applicable for Red Hat OpenShift 4.15."
  default     = false
}

variable "cluster_force_delete_storage" {
  type        = bool
  description = "Whether to delete persistent storage when the associated VPC cluster is deleted so that it can't be recovered. Set to true to force the removal of persistent storage. Set to false to skip the forceful deletion."
  default     = false
}

variable "operating_system" {
  type        = string
  description = "The operating system of the workers in the default worker pool. See https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions#openshift_versions_available ."
  validation {
    error_message = "RHEL 8 (REDHAT_8_64) or Red Hat Enterprise Linux CoreOS (RHCOS) are the allowed OS values. RHCOS requires VPC clusters created from 4.15 onwards. Upgraded clusters from 4.14 cannot use RHCOS."
    condition     = var.operating_system == "REDHAT_8_64" || var.operating_system == "RHCOS"
  }
}

# Exposing these two variables is necessary since GitHub Runtime cannot execute the verify_worker_network_readiness script during the upgrade test. We can remove these variables once we enable the ability to run upgrade tests through Schematics.
variable "verify_cluster_network_readiness" {
  type        = bool
  description = "By setting this to true, a script will run kubectl commands to verify that all worker nodes can communicate successfully with the master. If the runtime does not have access to the kube cluster to run kubectl commands, this should be set to false."
  default     = true
}

variable "use_ibm_cloud_private_api_endpoints" {
  type        = bool
  description = "Set this to true to force all api calls to use the IBM Cloud private endpoints."
  default     = true
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

variable "ssh_public_key" {
  description = "A public SSH key that does not exist in the deployment region. Used only if you provision F5 or Bastion Host. Must be an RSA key with a key size of either 2048 or 4096 bits (recommended). See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys. To use an existing key, specify a value in the `existing_ssh_key_name` variable instead."
  type        = string
  default     = null
  validation {
    error_message = "Public SSH Key must be a valid ssh rsa public key."
    condition     = var.ssh_public_key == null || can(regex("ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3} ?([^@]+@[^@]+)?", var.ssh_public_key))
  }
}

variable "existing_ssh_key_name" {
  description = "The name of a public SSH key that exists in the deployment region. Used only if you provision F5 or Bastion Host. To add a SSH key, use the `ssh_public_key` variable instead."
  type        = string
  default     = null
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
  default     = "ibm-ubuntu-24-04-6-minimal-amd64-1"
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
