##############################################################################
# Virtual Server Data
##############################################################################
locals {

  # Create list of VSI using subnets and VSI per subnet
  vsi_list = flatten([
    # For each subnet
    for subnet in range(length(var.subnets)) : [
      # For each number in a range from 0 to VSI per subnet
      for count in range(var.vsi_per_subnet) :
      {
        name        = "${var.prefix}-${(subnet) * (var.vsi_per_subnet) + count + 1}"
        subnet_id   = var.subnets[subnet].id
        zone        = var.subnets[subnet].zone
        subnet_name = var.subnets[subnet].name
      }
    ]
  ])

  # Create map of VSI from list
  vsi_map = {
    for server in local.vsi_list :
    server.name => server
  }

  secondary_fip_list = flatten([
    # For each interface in list of floating ips
    for interface in var.secondary_floating_ips :
    [
      # For each virtual server
      for instance in ibm_is_instance.vsi :
      {
        # fip name
        name = "${instance.name}-${interface}-fip"
        # target interface at the same index as subnet name
        target = instance.network_interfaces[index(var.secondary_subnets.*.name, interface)].id
      }
    ]
  ])
}

##############################################################################


##############################################################################
# Create Virtual Servers
##############################################################################

resource "ibm_is_instance" "vsi" {
  for_each       = local.vsi_map
  name           = each.key
  image          = var.image_id
  profile        = var.machine_type
  resource_group = var.resource_group_id
  vpc            = var.vpc_id
  zone           = each.value.zone
  user_data      = var.user_data
  keys           = var.ssh_key_ids

  primary_network_interface {
    subnet = each.value.subnet_id
    security_groups = flatten([
      (var.create_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
      var.security_group_ids
    ])
    allow_ip_spoofing = var.allow_ip_spoofing
  }

  dynamic "network_interfaces" {
    for_each = var.secondary_subnets == null ? [] : var.secondary_subnets
    content {
      subnet = network_interfaces.value.id
      security_groups = flatten([
        (var.create_security_group && var.secondary_use_vsi_security_group ? [ibm_is_security_group.security_group[var.security_group.name].id] : []),
        [
          for group in var.secondary_security_groups :
          group.security_group_id if group.interface_name == network_interfaces.value.name
        ]
      ])
      allow_ip_spoofing = var.secondary_allow_ip_spoofing
    }
  }

  boot_volume {
    encryption = var.boot_volume_encryption_key == "" ? null : var.boot_volume_encryption_key
  }

  # Only add volumes if volumes are being created by the module
  volumes = length(var.block_storage_volumes) == 0 ? [] : local.volume_by_vsi[each.key]
}



##############################################################################


##############################################################################
# Optionally create floating IP
##############################################################################

resource "ibm_is_floating_ip" "vsi_fip" {
  for_each = var.enable_floating_ip ? ibm_is_instance.vsi : {}
  name     = "${each.value.name}-fip"
  target   = each.value.primary_network_interface.0.id
}

resource "ibm_is_floating_ip" "secondary_fip" {
  for_each = length(var.secondary_floating_ips) == 0 ? {} : {
    for interface in local.secondary_fip_list :
    (interface.name) => interface
  }
  name   = each.key
  target = each.value.target
}

##############################################################################