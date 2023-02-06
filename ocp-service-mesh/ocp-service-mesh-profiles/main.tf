##############################################################################
# ocp-service-mesh-profiles
##############################################################################

module "public_ingress_config" {
  source      = "./public-ingress"
  vpc_lb_type = var.vpc_lb_type
}

module "public_egress_config" {
  source = "./public-egress"
}

module "transit_ingress_config" {
  source                 = "./transit-ingress"
  vpc_lb_type            = var.vpc_lb_type
  additional_sdnlb_ports = var.additional_sdnlb_ports
}

module "transit_egress_config" {
  source = "./transit-egress"
}

module "proxy_config" {
  source = "./proxy"
}

module "pilot_config" {
  source = "./pilot-runtime"
}
