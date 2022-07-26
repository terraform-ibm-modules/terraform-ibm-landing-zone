##############################################################################
# Teleport Config Variables
##############################################################################

variable "teleport_licence" {
  description = "The contents of the PEM license file"
  type        = string

}
variable "https_certs" {
  description = "The https certificate used by bastion host for teleport"
  type        = string

}
variable "https_key" {
  description = "The https private key used by bastion host for teleport"
  type        = string

}
variable "hostname" {
  description = "The name of the instance or bastion host"
  type        = string

}
variable "domain" {
  description = "The domain of the bastion host"
  type        = string

}
variable "cos_bucket" {
  description = "Name of COS instance"
  type        = string

}
variable "cos_bucket_endpoint" {
  description = "The endpoint of the COS bucket"
  type        = string

}

variable "hmac_access_key_id" {
  description = "The ID of the HMAC Access Key"
  type        = string

}

variable "hmac_secret_access_key_id" {
  description = "The ID of the secret HMAC Access Key"
  type        = string

}
variable "appid_client_id" {
  description = "The ID of the App ID client"
  type        = string

}
variable "appid_client_secret" {
  description = "The secret of the App ID client"
  type        = string

}
variable "appid_issuer_url" {
  description = "The URL of the App ID Issuer"
  type        = string

}
variable "teleport_version" {
  description = "Version of Teleport Enterprise to use"
  type        = string
}

variable "claim_to_roles" {
  description = "A list of maps that contain the user email and the role you want to associate with them"
  type = list(
    object({
      email = string
      roles = list(string)
    })
  )

}
variable "message_of_the_day" {
  description = "Banner message that is exposed to the user at authentication time"
  type        = string

}

##############################################################################
