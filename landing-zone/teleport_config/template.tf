##############################################################################
# Create Template Data to be used by Teleport VSI
##############################################################################

locals {
  user_data = templatefile(
    "${path.module}/cloud-init.tpl",
    {
      TELEPORT_LICENSE          = base64encode(tostring(var.TELEPORT_LICENSE)),
      HTTPS_CERT                = base64encode(tostring(var.HTTPS_CERT)),
      HTTPS_KEY                 = base64encode(tostring(var.HTTPS_KEY)),
      HOSTNAME                  = tostring(var.HOSTNAME),
      DOMAIN                    = tostring(var.DOMAIN),
      COS_BUCKET                = tostring(var.COS_BUCKET),
      COS_BUCKET_ENDPOINT       = tostring(var.COS_BUCKET_ENDPOINT)
      HMAC_ACCESS_KEY_ID        = tostring(var.HMAC_ACCESS_KEY_ID),
      HMAC_SECRET_ACCESS_KEY_ID = tostring(var.HMAC_SECRET_ACCESS_KEY_ID),
      APPID_CLIENT_ID           = tostring(var.APPID_CLIENT_ID),
      APPID_CLIENT_SECRET       = tostring(var.APPID_CLIENT_SECRET),
      APPID_ISSUER_URL          = tostring(var.APPID_ISSUER_URL),
      TELEPORT_VERSION          = tostring(var.TELEPORT_VERSION),
      CLAIM_TO_ROLES            = var.CLAIM_TO_ROLES,
      MESSAGE_OF_THE_DAY        = tostring(var.MESSAGE_OF_THE_DAY)
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
