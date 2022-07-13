##############################################################################
# Locals
##############################################################################

locals {
  ssh_key_id        = var.ssh_key != null ? data.ibm_is_ssh_key.existing_ssh_key[0].id : resource.ibm_is_ssh_key.ssh_key[0].id
}

##############################################################################
# Create new SSH key
##############################################################################
resource "tls_private_key" "tls_key" {
  count     = var.ssh_key != null ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  count      = var.ssh_key != null ? 0 : 1
  name       = "${var.prefix}-ssh-key"
  public_key = resource.tls_private_key.tls_key[0].public_key_openssh
}

data "ibm_is_ssh_key" "existing_ssh_key" {
  count = var.ssh_key != null ? 1 : 0
  name  = var.ssh_key
}

module "landing-zone" {
  source                         = "../../patterns/vsi"
  prefix                         = var.prefix
  region                         = var.region
  ibmcloud_api_key               = var.ibmcloud_api_key
  ssh_public_key                 = tls_private_key.tls_key[0].public_key_openssh
}
