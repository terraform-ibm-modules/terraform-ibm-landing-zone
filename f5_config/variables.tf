##################################################################################
# VPC Variables
##################################################################################

variable "vpc_id" {
  description = "The VPC ID where the instance will be provisioned"
  type        = string
}

variable "zone" {
  description = "Zone where the instance will be provisioned"
  type        = string
}

variable "secondary_subnets" {
  description = "List of secondary network interfaces to add to vsi secondary subnets must be in the same zone as VSI. This is only recommended for use with a deployment of 1 VSI."
  type = list(
    object({
      name = string
      id   = string
      zone = string
      cidr = string
    })
  )
  default = []
}

##################################################################################


##################################################################################
# F5 Config Variables
##################################################################################

variable "default_route_interface" {
  description = "The F5 BIG-IP interface name for the default route. Leave null to auto assign."
  type        = string
  default     = null
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
}

##################################################################################


##################################################################################
# A&O Declaration Sources
##################################################################################

variable "license_type" {
  description = "License, may be 'none','byol','regkeypool','utilitypool'"
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
}

variable "license_host" {
  description = "BIGIQ IP or hostname to use for pool based licensing of the F5 BIG-IP instance"
  type        = string
}

variable "license_username" {
  description = "BIGIQ username to use for the pool based licensing of the F5 BIG-IP instance"
  type        = string
}

variable "license_password" {
  description = "BIGIQ password to use for the pool based licensing of the F5 BIG-IP instance"
  type        = string
  sensitive   = true
}

variable "license_pool" {
  description = "BIGIQ license pool name of the pool based licensing of the F5 BIG-IP instance"
  type        = string
}

variable "license_sku_keyword_1" {
  description = "BIGIQ primary SKU for ELA utility licensing of the F5 BIG-IP instance"
  type        = string
}

variable "license_sku_keyword_2" {
  description = "BIGIQ secondary SKU for ELA utility licensing of the F5 BIG-IP instance"
  type        = string
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

##################################################################################

##################################################################################
# phone_home_url - The web hook URL to POST status to when F5 BIG-IP onboarding completes
##################################################################################

variable "phone_home_url" {
  description = "The URL to POST status when BIG-IP is finished onboarding"
  type        = string
  default     = "null"
}

##################################################################################

##################################################################################
# schematic template for phone_home_url_metadata
##################################################################################

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

##################################################################################
