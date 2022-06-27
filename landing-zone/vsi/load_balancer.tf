##############################################################################
# Load Balancer
##############################################################################

locals {
  load_balancer_map = {
    for load_balancer in var.load_balancers :
    (load_balancer.name) => load_balancer
  }
}

resource "ibm_is_lb" "lb" {
  for_each        = local.load_balancer_map
  name            = "${var.prefix}-${each.value.name}-lb"
  subnets         = var.subnets.*.id
  type            = each.value.type
  security_groups = each.value.security_group == null ? null : [ibm_is_security_group.security_group[each.value.security_group.name].id]
  resource_group  = var.resource_group_id
  tags            = var.tags
}

##############################################################################


##############################################################################
# Load Balancer Pool
##############################################################################

resource "ibm_is_lb_pool" "pool" {
  for_each       = local.load_balancer_map
  lb             = ibm_is_lb.lb[each.value.name].id
  name           = "${var.prefix}-${each.value.name}-lb-pool"
  algorithm      = each.value.algorithm
  protocol       = each.value.protocol
  health_delay   = each.value.health_delay
  health_retries = each.value.health_retries
  health_timeout = each.value.health_timeout
  health_type    = each.value.health_type
}

##############################################################################

##############################################################################
# Load Balancer Pool Member
##############################################################################

locals {
  pool_members = flatten([
    for load_balancer in var.load_balancers :
    [
      for ipv4_address in [
        for server in ibm_is_instance.vsi :
        lookup(server, "primary_network_interface", null) == null ? null : server.primary_network_interface.0.primary_ipv4_address
      ] :
      {
        port           = load_balancer.pool_member_port
        target_address = ipv4_address
        lb             = load_balancer.name
      }
    ]
  ])
}

resource "ibm_is_lb_pool_member" "pool_members" {
  count          = length(local.pool_members)
  port           = local.pool_members[count.index].port
  lb             = ibm_is_lb.lb[local.pool_members[count.index].lb].id
  pool           = element(split("/", ibm_is_lb_pool.pool[local.pool_members[count.index].lb].id), 1)
  target_address = local.pool_members[count.index].target_address
}

##############################################################################



##############################################################################
# Load Balancer Listener
##############################################################################

resource "ibm_is_lb_listener" "listener" {
  for_each         = local.load_balancer_map
  lb               = ibm_is_lb.lb[each.value.name].id
  default_pool     = ibm_is_lb_pool.pool[each.value.name].id
  port             = each.value.listener_port
  protocol         = each.value.listener_protocol
  connection_limit = each.value.connection_limit > 0 ? each.value.connection_limit : null
  depends_on       = [ibm_is_lb_pool_member.pool_members]
}

##############################################################################