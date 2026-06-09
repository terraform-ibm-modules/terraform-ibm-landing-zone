provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = var.provider_visibility
}
