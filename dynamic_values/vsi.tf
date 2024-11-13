##############################################################################
# VSI Creation Values
# > VSI deployments
# > ssh key creation
# > VSI Image Templates
##############################################################################

module "vsi" {
  source          = "./config_modules/vsi"
  prefix          = var.prefix
  resource_groups = var.resource_groups
  ssh_keys        = var.ssh_keys
  vpc_modules     = var.vpc_modules
  vsi             = var.vsi
  bastion_vsi     = var.bastion_vsi
  user_data       = var.user_data
}

##############################################################################

##############################################################################
# [Unit Test] SSH Keys Added resource group
##############################################################################

module "ut_ssh_key" {
  source = "./config_modules/vsi"
  prefix = "ut"
  resource_groups = {
    default = "defaultrg"
    prod    = "prodrg"
  }
  ssh_keys = [
    {
      name           = "default-key"
      resource_group = "default"
    },
    {
      name = "null-rg-key"
    },
    {
      name           = "prod-key"
      resource_group = "prod"
    }
  ]
  vpc_modules = {}
  user_data   = {}
  vsi         = []
  bastion_vsi = []
}

locals {
  ut_ssh_key_rg_ids           = module.ut_ssh_key.ssh_key_list.*.resource_group_id
  ut_ssh_key_correct_rg_ids   = regex("true", local.ut_ssh_key_rg_ids[1] == null)
  ut_ssh_key_correct_with_key = regex("defaultrg;prodrg", join(";", [local.ut_ssh_key_rg_ids[0], local.ut_ssh_key_rg_ids[2]]))
}

##############################################################################

##############################################################################
# [Unit Test] VSI and Images
##############################################################################

module "ut_vsi_images" {
  source          = "./config_modules/vsi"
  prefix          = "ut"
  resource_groups = {}
  ssh_keys        = []
  user_data       = {}
  vpc_modules = {
    test = {
      vpc_id = "1234"
      subnet_zone_list = [
        {
          name = "ut-test-subnet-1"
          id   = "1-id"
          zone = "1-zone"
          cidr = "1"
        },
        { name = "ut-test-subnet-2"
          id   = "2-id"
          zone = "2-zone"
          cidr = "2"
        },
        {
          name = "ut-test-subnet-3"
          id   = "3-id"
          zone = "3-zone"
          cidr = "3"
        },
      ]
    }
  }
  vsi = [
    {
      name         = "vsi-group"
      vpc_name     = "test"
      subnet_names = ["ut-test-subnet-1"]
      image_name   = "dev"
    }
  ]
  bastion_vsi = [
    {
      name         = "bastion-vsi-group"
      vpc_name     = "test"
      subnet_names = ["ut-test-subnet-2"]
      image_name   = "bastion-dev"
    }
  ]
}

locals {
  ut_vsi_images_keys                    = join(";", keys(module.ut_vsi_images.vsi_image_map))
  ut_vsi_images_contains_correct_images = regex("ut-bastion-vsi-group;ut-vsi-group", local.ut_vsi_images_keys)
  ut_vsi_image_names                    = join(";", [for image in ["ut-bastion-vsi-group", "ut-vsi-group"] : module.ut_vsi_images.vsi_image_map[image].image_name])
  ut_vsi_images_correct_image_name      = regex("bastion-dev;dev", local.ut_vsi_image_names)
  ut_vsi_images_actual_vsi_map          = module.ut_vsi_images.vsi_map
  ut_vsi_correct_vpc_id                 = regex("1234", local.ut_vsi_images_actual_vsi_map["ut-vsi-group"].vpc_id)
  ut_vsi_correct_subnets                = regex("1", length(local.ut_vsi_images_actual_vsi_map["ut-vsi-group"].subnets))
}

##############################################################################
