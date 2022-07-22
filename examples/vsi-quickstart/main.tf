module "landing_zone" {
  source                   = "../../patterns/vsi"
  prefix                   = var.prefix
  region                   = var.region
  tags                     = var.tags
  ibmcloud_api_key         = var.ibmcloud_api_key
  ssh_public_key           = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCoJta6Q4CRFdxRnu4h1cmXMvXRAj4taj5X+/9FVFPDKJ77mU1z6xi/5RJuVnFFshRcZlIUbP8QLSclUUTGpquU24AqfoF4Tj3fLHBTPP5SKI6q9dIquv0WZkt5I9Um89ccrLioIsr5kdrxykmbbkIxfKX4xNLWTjS3f68GdK2Iid/tPR+SAwBPd5xbhdgD+A6MXkfA12doc6aYZGEo0Qi3dMbY8NOVuvHMDQhrn453qriabji63wGjeRILS/fcifKTe4DNo6zqLdjtc76BLVKPkMAUeXAlnWAzubHIFJ0XSgDqeafF2hB+9zsPCapsCWfHqM/qf+lquQ54MiybKVJ5Wi729fbM3mSrtc7I3cj8YUpZSeeszXw/yGlsTxmVPTfo7phqr53MGYaiK8I5kdIfOmQAj5yeWlBVDzSC/BGwa4uVCU9Ppi6fXyFrhD5bwdP79xmb+oaRpLIpiozadDZkS96hIfjWPl2kLLAbGHqpT9CbxvNsj1PuqeYZyeFN823WRhdruhdPiJW3DAyvyY3PYNnachSQ62YOTCJKvfWnjd1j697Auj/dJRv2c1JAcsv0G/McItbaghCVhytyNc/qyRl4kV9ieibBIePY6CuTC5gBo3ccKCLezUwkggRuAnKIS79+DH8881Y6BCaLhROffCQOlHNf++Glmbc/I5O5Q=="
  tf_version               = "1.0"
  network_cidr             = var.network_cidr
  vpcs                     = var.vpcs
  enable_transit_gateway   = var.enable_transit_gateway
  add_atracker_route       = var.add_atracker_route
  hs_crypto_instance_name  = var.hs_crypto_instance_name
  hs_crypto_resource_group = var.hs_crypto_resource_group
  vsi_image_name           = var.vsi_image_name
  vsi_instance_profile     = var.vsi_instance_profile
  vsi_per_subnet           = var.vsi_per_subnet
  use_random_cos_suffix    = var.use_random_cos_suffix
}
