##############################################################################
# Create Template Data to be used by Teleport VSI
##############################################################################

locals {
  user_data = templatefile(
    "${path.module}/cloud-init.tpl",
    {
      TELEPORT_LICENSE          = base64encode(tostring(var.teleport_licence)),
      HTTPS_CERT                = base64encode(tostring(var.https_certs)),
      HTTPS_KEY                 = base64encode(tostring(var.https_key)),
      HOSTNAME                  = tostring(var.hostname),
      DOMAIN                    = tostring(var.domain),
      COS_BUCKET                = tostring(var.cos_bucket),
      COS_BUCKET_ENDPOINT       = tostring(var.cos_bucket_endpoint)
      HMAC_ACCESS_KEY_ID        = tostring(var.hmac_access_key_id),
      HMAC_SECRET_ACCESS_KEY_ID = tostring(var.hmac_secret_access_key_id),
      APPID_CLIENT_ID           = tostring(var.appid_client_id),
      APPID_CLIENT_SECRET       = tostring(var.appid_client_secret),
      APPID_ISSUER_URL          = tostring(var.appid_issuer_url),
      TELEPORT_VERSION          = tostring(var.teleport_version),
      CLAIM_TO_ROLES            = var.claim_to_roles,
      MESSAGE_OF_THE_DAY        = tostring(var.message_of_the_day)
    }
  )
}

data "template_cloudinit_config" "cloud_init" {
  base64_encode = false
  gzip          = false
  part {
    content = local.user_data
  }
}

##############################################################################
