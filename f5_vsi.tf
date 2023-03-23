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
    f5-bigip-16-1-3-3-0-0-3-all-1slot = {
      "eu-de"    = "r010-df45998a-7c98-40ae-9b25-e908331fb76a"
      "jp-tok"   = "r022-cc145b83-92d2-4129-b311-bd2b78fb2172"
      "br-sao"   = "r042-445d3dbf-f516-4213-9a78-0bfc0b540d05"
      "au-syd"   = "r026-1d361ae2-35dd-4ff3-a7b8-93f26614fe52"
      "us-south" = "r006-30804d17-d907-4ca9-9167-4fa7e75bc511"
      "eu-gb"    = "r018-0d4f8035-c26a-48b1-93b3-ec970e47cf40"
      "jp-osa"   = "r034-a22aceff-5f2e-4837-880c-d4576303e21f"
      "us-east"  = "r014-b236bd8f-2253-4606-ac51-a7fa1dadafae"
      "eu-fr2"   = "r030-13ff5014-3589-491f-915a-72368b7f6566"
      "ca-tor"   = "r038-7fa7a5b3-859a-4abc-ab97-f2d7203b4a5d"
    },
    f5-bigip-16-1-3-3-0-0-3-ltm-1slot = {
      "eu-de"    = "r010-78bd2415-d791-45a6-91b4-24e069ef63bd"
      "jp-tok"   = "r022-b93a6ccc-59e7-47dc-b9e4-f9a5a2ee93d1"
      "br-sao"   = "r042-3f2eaa4c-8417-4670-8974-d434612c765a"
      "au-syd"   = "r026-0cf76d10-db18-499f-86a5-5905ac612da4"
      "us-south" = "r006-09fa4dd7-1a7f-453c-a15e-53cf6effbda6"
      "eu-gb"    = "r018-8b8ea452-b51c-4b20-a16a-403aea05a745"
      "jp-osa"   = "r034-7ef8a732-a7f1-48d9-a13e-ad6588e74c72"
      "us-east"  = "r014-b28c4e45-0327-4e25-8bbc-5f48ae2c8e68"
      "eu-fr2"   = "r030-a1826148-e6d6-47e1-bab0-7b261cd23ae5"
      "ca-tor"   = "r038-b4856c18-f700-40d5-b574-bd55fb95bbbf"
    },

    f5-bigip-17-0-0-2-0-0-2-ltm-1slot = {
      "eu-de"    = "r010-8927cbf1-bd81-4586-bba3-10949f8b77cb"
      "jp-tok"   = "r022-6fa37b30-e912-41e2-95ba-49c12e0a8d65"
      "br-sao"   = "r042-d24cc495-1bcd-4916-858f-8834619f16e2"
      "au-syd"   = "r026-0614e6ee-aec3-4cdc-9c48-c2757f3fcfb3"
      "us-south" = "r006-493db1ca-0b14-45e8-a222-69b9d0863a76"
      "eu-gb"    = "r018-a54d67dd-90c1-4983-bf93-258babf1ba44"
      "jp-osa"   = "r034-0625faf6-dec7-4429-98ba-7e2bbf4ed08e"
      "us-east"  = "r014-c6f1f733-5c37-4b6f-afb6-270af44b2247"
      "eu-fr2"   = "r030-b3f84f0b-fc46-4996-a52b-3c4006a9f835"
      "ca-tor"   = "r038-6e3b58fd-cb3e-4fef-8882-dd0164d9e8aa"
    },
    f5-bigip-17-0-0-2-0-0-2-all-1slot = {
      "eu-de"    = "r010-33e49d35-0df8-4dc9-a247-56ecce82b986"
      "jp-tok"   = "r022-f72249df-075b-4cf3-9969-2acf80298b4c"
      "br-sao"   = "r042-e09ac580-af33-4eb3-9343-64f4732d69eb"
      "au-syd"   = "r026-4f01da0c-17a8-48d6-85b1-daeb21c436f7"
      "us-south" = "r006-19fada8f-8dcd-4c27-afe9-1cc77bcd6ceb"
      "eu-gb"    = "r018-30ab931f-371b-4424-b34d-dfc25341f523"
      "jp-osa"   = "r034-c9d1a792-85b2-4c01-89be-98f63af3cc97"
      "us-east"  = "r014-4e8014e2-9133-4034-8035-a4913c15ae59"
      "eu-fr2"   = "r030-1e803de2-1ae6-4624-b467-31dbbb69c150"
      "ca-tor"   = "r038-8ceba776-b7e7-4ce4-b805-cd059a24037b"
    }
  }
}

##############################################################################


##############################################################################
# Create F5
##############################################################################

module "f5_vsi" {
  source                      = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi.git?ref=v2.0.0"
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
