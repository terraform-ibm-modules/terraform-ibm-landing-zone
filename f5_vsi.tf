##############################################################################
# Create F5 VSI
##############################################################################

locals {
  f5_vsi_map = module.dynamic_values.f5_vsi_map
}

##############################################################################

##############################################################################
# F5 Image IDs
##############################################################################

locals {
  # use the public image if the name is found
  # List of public images found in F5 schematics documentation
  # (https://github.com/f5devcentral/ibmcloud_schematics_bigip_multinic_public_images)
  public_image_map = {
    f5-bigip-15-1-5-1-0-0-14-all-1slot = {
      "eu-de"    = "r010-b14deae9-43fd-4850-b89d-5d6485d61acb"
      "jp-tok"   = "r022-cfdb6280-c200-4261-af3a-a8d44bbd18ba"
      "br-sao"   = "r042-3915f0e3-aadc-4fc9-95a8-840f8cb163de"
      "au-syd"   = "r026-ed57accf-b3d4-4ca9-a6a6-e0a63ee1aba4"
      "us-south" = "r006-c9f07041-bb56-4492-b25c-5f407ebea358"
      "eu-gb"    = "r018-6dce329f-a6eb-4146-ba3e-5560afc84aa1"
      "jp-osa"   = "r034-4ecc10ff-3dc7-42fb-9cae-189fb559dd61"
      "us-east"  = "r014-87371e4c-3645-4579-857c-7e02fe5e9ff4"
      "ca-tor"   = "r038-0840034f-5d05-4a6d-bdae-123628f1d323"
    }
    f5-bigip-15-1-5-1-0-0-14-ltm-1slot = {
      "eu-de"    = "r010-efad005b-4deb-45a8-b1c5-5b3cea55e7e3"
      "jp-tok"   = "r022-35126a90-aec2-4934-a628-d1ce90bcf68a"
      "br-sao"   = "r042-978cecaf-7f2a-44bc-bffd-ddcf6ce56b11"
      "au-syd"   = "r026-429369e1-d917-4d9c-8a8c-3a8606e26a72"
      "us-south" = "r006-afe3c555-e8ba-4448-9983-151a14edf868"
      "eu-gb"    = "r018-f2083d86-6f25-42d6-b66a-d5ed2a0108d2"
      "jp-osa"   = "r034-edd01010-b7ee-411c-9158-d41960bf9def"
      "us-east"  = "r014-41db5a03-ab7f-4bf7-95c2-8edbeea0e3af"
      "ca-tor"   = "r038-f5d750b1-61dc-4fa5-98d3-a790417f07dd"
    }
    f5-bigip-16-1-2-2-0-0-28-ltm-1slot = {
      "eu-de"    = "r010-c90f3597-d03e-4ce6-8efa-870c782952cd"
      "jp-tok"   = "r022-0da3fc1b-c243-4702-87cc-b5a7f5e1f035"
      "br-sao"   = "r042-0649e2fc-0d27-4950-99a8-1d968bc72dd5"
      "au-syd"   = "r026-9de34b46-fc95-4940-a074-e45ac986c761"
      "us-south" = "r006-863f431b-f4e2-4d8c-a358-07746a146ea1"
      "eu-gb"    = "r018-a88026c2-89b4-43d6-8688-f28ac259627d"
      "jp-osa"   = "r034-585692ec-9508-4a41-bcc3-3a94b31ad161"
      "us-east"  = "r014-b675ae9f-109d-4499-9639-2fbc7b1d55e9"
      "ca-tor"   = "r038-56cc321b-1920-443e-a400-c58905c8f46c"
    }
    f5-bigip-16-1-2-2-0-0-28-all-1slot = {
      "eu-de"    = "r010-af6fa90b-ea18-48af-bfb9-a3605d60224d"
      "jp-tok"   = "r022-d2bffe3c-084e-43ae-b331-ec82b15af705"
      "br-sao"   = "r042-2dcd1226-5dd9-4b8d-89c5-5ba4f162b966"
      "au-syd"   = "r026-1f8b30f1-af86-433d-861c-7ff36d69176b"
      "us-south" = "r006-1c0242c4-a99c-4d27-ad2c-4003a7fea131"
      "eu-gb"    = "r018-d33e87cb-0342-41e2-8e29-2b0db4a5881f"
      "jp-osa"   = "r034-1b04698d-9935-4477-8f72-958c7f08c85f"
      "us-east"  = "r014-015d6b06-611e-4e1a-9284-551ed3832182"
      "ca-tor"   = "r038-b7a44268-e95f-425b-99ac-6ec5fc2c4cdc"
    },
    f5-bigip-16-1-3-2-0-0-4-ltm-1slot = {
      "eu-de"    = "r010-d38b9af9-b345-40e6-8d7a-34cdfb7ffef9"
      "jp-tok"   = "r022-4dc47d5a-a8eb-4e85-8bda-928db1067354"
      "br-sao"   = "r042-28930d14-46ab-4784-b2f4-e56d0e4eddfc"
      "au-syd"   = "r026-c9f7699f-9e06-4802-a3a3-3b03ef429c04"
      "us-south" = "r006-301cece1-59cf-4e71-a0e2-6be355b692b5"
      "eu-gb"    = "r018-34c9cfcc-84d6-431a-9e92-f523c6705742"
      "jp-osa"   = "r034-18e41455-9c8c-4ecf-8264-ff2070a76610"
      "us-east"  = "r014-7f427b96-c39d-40f7-8f06-2da6e4c63250"
      "ca-tor"   = "r038-aeeb05de-061e-40e2-b176-827d343de934"
    },
    f5-bigip-16-1-3-2-0-0-4-all-1slot = {
      "eu-de"    = "r010-92ba59fd-36b1-4ca5-a7c1-4581d10eed3a"
      "jp-tok"   = "r022-32b33469-1b9d-49eb-8304-b287463849aa"
      "br-sao"   = "r042-5195b226-d799-415d-99e2-61868995a825"
      "au-syd"   = "r026-495c8dc6-f8e1-4df8-bcdd-98824f3673e5"
      "us-south" = "r006-51cd6c1d-60db-4bb4-8fd8-675a49403246"
      "eu-gb"    = "r018-7d2d2177-6e4b-4f57-9896-bd95077f2394"
      "jp-osa"   = "r034-efd9e396-046d-4f55-b452-d467a3183ab4"
      "us-east"  = "r014-0d1f83ba-54a3-48de-904c-f4806e03ebde"
      "ca-tor"   = "r038-d9e0b718-1b84-45ef-b603-45a00a768656"
    },
    f5-bigip-17-0-0-1-0-0-4-ltm-1slot = {
      "eu-de"    = "r010-6e13ce99-e218-4837-b77a-b1a097cdb8be"
      "jp-tok"   = "r022-1a81f5b9-f178-46d6-9546-f6222f51ac09"
      "br-sao"   = "r042-0aa78ebd-3629-4f71-a225-d057ed910b19"
      "au-syd"   = "r026-ad311315-1cbf-4e38-b4da-334115ec5777"
      "us-south" = "r006-612682f9-b709-41f2-a000-7c7583d6a79b"
      "eu-gb"    = "r018-58ac90dd-4ab6-4580-899b-ccb7a6cb0486"
      "jp-osa"   = "r034-d735d37d-90f3-4a5c-9318-320630cfcb8d"
      "us-east"  = "r014-538006c7-99b2-40ae-bb56-98626510b59c"
      "ca-tor"   = "r038-cc51e1d4-f29f-40d9-b45d-1fe93dd7bf25"
    },
    f5-bigip-17-0-0-1-0-0-4-all-1slot = {
      "eu-de"    = "r010-9920ae90-8a5a-4d6e-bb39-8e124cfb6b36"
      "jp-tok"   = "r022-9c278b7c-a74e-4db9-a037-af6ddff94fc5"
      "br-sao"   = "r042-9d99efd6-eec5-45bd-90b5-51b095ff9347"
      "au-syd"   = "r026-f75351ef-86b2-4966-82f0-5de9e38e2b04"
      "us-south" = "r006-7256a080-1a1b-415e-a449-9fc0fb40e209"
      "eu-gb"    = "r018-b4db281f-c397-4e15-92b5-3e9b17014815"
      "jp-osa"   = "r034-dbad3304-d79b-42ec-8c05-b210c21f6840"
      "us-east"  = "r014-f424a008-2778-484a-89e2-8ca0146fbc74"
      "ca-tor"   = "r038-269cb902-3aa1-4fc2-b59e-e050af80baac"
    }
  }
}

##############################################################################


##############################################################################
# Create F5
##############################################################################

module "f5_vsi" {
  source                      = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi.git?ref=v1.1.7"
  for_each                    = local.f5_vsi_map
  resource_group_id           = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  create_security_group       = each.value.security_group == null ? false : true
  prefix                      = "${var.prefix}-${each.value.name}"
  vpc_id                      = module.vpc[each.value.vpc_name].vpc_id
  subnets                     = each.value.subnets
  secondary_subnets           = each.value.secondary_subnets
  secondary_allow_ip_spoofing = true
  secondary_security_groups = [
    for group in each.value.secondary_subnet_security_group_names :
    {
      security_group_id = ibm_is_security_group.security_group[group.group_name].id
      interface_name    = group.interface_name
    }
  ]
  image_id       = lookup(local.public_image_map[each.value.f5_image_name], var.region)
  user_data      = module.dynamic_values.f5_template_map[each.key].user_data
  machine_type   = each.value.machine_type
  vsi_per_subnet = 1
  security_group = each.value.security_group
  load_balancers = each.value.load_balancers == null ? [] : each.value.load_balancers
  # Get boot volume
  boot_volume_encryption_key = each.value.boot_volume_encryption_key_name == null ? "" : [
    for keys in module.key_management.keys :
    keys.id if keys.name == each.value.boot_volume_encryption_key_name
  ][0]
  # Get security group ids
  security_group_ids = each.value.security_groups == null ? [] : [
    for group in each.value.security_groups :
    ibm_is_security_group.security_group[group].id
  ]
  # Get ssh keys
  ssh_key_ids = [
    for ssh_key in each.value.ssh_keys :
    lookup(module.ssh_keys.ssh_key_map, ssh_key).id
  ]
  # Get block storage volumes
  block_storage_volumes = each.value.block_storage_volumes == null ? [] : [
    # For each block storage volume
    for volume in each.value.block_storage_volumes :
    # Merge volume and add encryption key
    {
      name     = volume.name
      profile  = volume.profile
      capacity = volume.capacity
      iops     = volume.iops
      encryption_key = lookup(volume, "encryption_key", null) == null ? null : [
        for key in module.key_management.keys :
        key.id if key.name == volume.encryption_key
      ][0]
    }
  ]
  enable_floating_ip = each.value.enable_management_floating_ip == true ? true : false
  secondary_floating_ips = each.value.enable_external_floating_ip == true ? [
    for subnet in each.value.secondary_subnets :
    subnet.name if can(regex("external", subnet.name))
  ] : []
  depends_on = [module.ssh_keys]
}

##############################################################################
