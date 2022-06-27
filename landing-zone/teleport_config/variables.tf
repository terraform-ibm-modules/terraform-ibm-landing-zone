##############################################################################
# Teleport Config Variables
##############################################################################

variable "TELEPORT_LICENSE" {
  description = "The contents of the PEM license file"
  type        = string

}
variable "HTTPS_CERT" {
  description = "The https certificate used by bastion host for teleport"
  type        = string

}
variable "HTTPS_KEY" {
  description = "The https private key used by bastion host for teleport"
  type        = string

}
variable "HOSTNAME" {
  description = "The name of the instance or bastion host"
  type        = string

}
variable "DOMAIN" {
  description = "The domain of the bastion host"
  type        = string

}
variable "COS_BUCKET" {
  description = "Name of COS instance"
  type        = string

}
variable "COS_BUCKET_ENDPOINT" {
  description = "The endpoint of the COS bucket"
  type        = string

}

variable "HMAC_ACCESS_KEY_ID" {
  description = "The ID of the HMAC Access Key"
  type        = string

}

variable "HMAC_SECRET_ACCESS_KEY_ID" {
  description = "The ID of the secret HMAC Access Key"
  type        = string

}
variable "APPID_CLIENT_ID" {
  description = "The ID of the App ID client"
  type        = string

}
variable "APPID_CLIENT_SECRET" {
  description = "The secret of the App ID client"
  type        = string

}
variable "APPID_ISSUER_URL" {
  description = "The URL of the App ID Issuer"
  type        = string

}
variable "TELEPORT_VERSION" {
  description = "Version of Teleport Enterprise to use"
  type        = string
}

variable "CLAIM_TO_ROLES" {
  description = "A list of maps that contain the user email and the role you want to associate with them"
  type = list(
    object({
      email = string
      roles = list(string)
    })
  )

}
variable "MESSAGE_OF_THE_DAY" {
  description = "Banner message that is exposed to the user at authentication time"
  type        = string

}

##############################################################################