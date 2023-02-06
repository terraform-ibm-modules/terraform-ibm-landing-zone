##############################################################################
# OCP Service Mesh
#
# Deploy the Service Mesh operator on an OCP cluster, if needed, and set up
# one or several service mesh control plane(s)
##############################################################################

##############################################################################
# Locals
##############################################################################

locals {
  operator_namespace = "openshift-operators"

  chart_name_sm_operator      = "service-mesh"
  chart_name_sm_control_plane = "service-mesh-control-plane"
  chart_name_sm_cse_proxy     = "service-mesh-cse-proxy"
  controlplanes_config        = var.service_mesh_control_planes
  subnet_values               = <<EOT
%{if length(var.lb_subnet_ids) > 0~}
lb_subnets:
%{for subnet in var.lb_subnet_ids~}
  - ${subnet}
%{endfor~}
%{endif~}
EOT
  subnet_zone_values          = <<EOT
%{if length(var.lb_subnet_ids_and_zones) > 0~}
lb_subnet_ids_and_zones:
%{for subnet_id, subnet_zone in var.lb_subnet_ids_and_zones~}
  ${subnet_id}: ${subnet_zone}
%{endfor~}
%{endif~}
EOT

  # Wait periods are overally conservative on purpose to cover majority of case. Divide them by 10 during dev
  sleep_create  = var.develop_mode ? "60s" : "600s"
  sleep_destroy = var.develop_mode ? "36s" : "360s"

  validate_ibmcloud_api_key_cnd = var.create_ingress_subdomains == true && var.ibmcloud_api_key == null
  validate_ibmcloud_api_key_msg = "ibmcloud_api_key must also be set when create_ingress_subdomains is set to true."
  # tflint-ignore: terraform_unused_declarations
  validate_ibmcloud_api_key_chk = regex(
    "^${local.validate_ibmcloud_api_key_msg}$",
    (!local.validate_ibmcloud_api_key_cnd
      ? local.validate_ibmcloud_api_key_msg
  : ""))

}

##############################################################################
# Retrieve information about all the Kubernetes configuration files and
# certificates to access the cluster in order to run kubectl / oc commands
##############################################################################

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id = var.cluster_id
  config_dir      = "${path.module}/kubeconfig" # See https://github.ibm.com/GoldenEye/issues/issues/552
}

##############################################################################
# RedHat Service Mesh Operator, and its dependencies
##############################################################################

resource "helm_release" "service_mesh_operator" {
  depends_on = [data.ibm_container_cluster_config.cluster_config]
  count      = var.deploy_operators == true ? 1 : 0

  name              = local.chart_name_sm_operator
  chart             = "${path.module}/chart/${local.chart_name_sm_operator}"
  namespace         = local.operator_namespace
  create_namespace  = true
  timeout           = 300
  dependency_update = true
  force_update      = false
  cleanup_on_fail   = false
  wait              = true

  disable_openapi_validation = false

  set {
    name  = "operators.namespace"
    type  = "string"
    value = local.operator_namespace
  }

  provisioner "local-exec" {
    command     = "${path.module}/scripts/approve-install-plan.sh ${local.operator_namespace}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

# On create: give time for the istio pod operator to warm-up up (see bug report for RH linked at https://github.ibm.com/GoldenEye/issues/issues/58#issuecomment-33498647)
# On delete: give time for the crd sm instance to be removed (which depends on running finalizer)
# Cheap for now - replace with polling of specific resources
resource "time_sleep" "wait_operators" {
  depends_on = [helm_release.service_mesh_operator[0]]

  create_duration  = local.sleep_create
  destroy_duration = local.sleep_destroy
}

##############################################################################
# Control plane namespace(s)
##############################################################################

resource "kubernetes_namespace" "controlplane_namespace" {
  depends_on = [helm_release.service_mesh_operator[0]]
  for_each   = toset(var.service_mesh_control_planes[*].namespace)

  metadata {
    name = each.key
  }

  timeouts {
    delete = "30m"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}

##############################################################################
# Service Mesh Control Plane(s)
##############################################################################

resource "helm_release" "service_mesh_control_plane" {
  depends_on = [time_sleep.wait_operators, kubernetes_namespace.controlplane_namespace]

  name              = local.chart_name_sm_control_plane
  chart             = "${path.module}/chart/${local.chart_name_sm_control_plane}"
  timeout           = 600
  dependency_update = true
  force_update      = false
  cleanup_on_fail   = false
  wait              = true

  disable_openapi_validation = false

  values = [yamlencode({
    controlplanes = local.controlplanes_config
  }), local.subnet_values, local.subnet_zone_values]
}

##############################################################################
# Confirm istio operational
##############################################################################

resource "null_resource" "confirm_istio_operational" {

  depends_on = [helm_release.service_mesh_control_plane]
  for_each   = toset(var.service_mesh_control_planes[*].namespace)

  provisioner "local-exec" {
    command     = "${path.module}/scripts/confirm-istio-operational.sh ${each.key}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

##############################################################################
# Deleting the default route for istio-ingressgateway
# The VPC Load Balancer that is created by the istio-ingressgateway service
# will be used instead of the OpenShift route. The route will not get recreated
# since it is disabled in the servicemesh-control-plane.yaml.
##############################################################################

resource "null_resource" "delete_default_route_istio_ingressgateway" {

  depends_on = [null_resource.confirm_istio_operational]
  for_each   = toset(var.service_mesh_control_planes[*].namespace)

  provisioner "local-exec" {
    command     = "${path.module}/scripts/delete-route.sh ${each.key}"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path
    }
  }
}

##############################################################################
# CSE Proxy
##############################################################################

resource "helm_release" "service_mesh_cse_proxy" {
  depends_on = [null_resource.confirm_istio_operational]

  name              = local.chart_name_sm_cse_proxy
  chart             = "${path.module}/chart/${local.chart_name_sm_cse_proxy}"
  timeout           = 600
  dependency_update = true
  force_update      = false
  cleanup_on_fail   = false
  wait              = true

  disable_openapi_validation = false

  values = [yamlencode({
    controlplanes = local.controlplanes_config
  })]
}

##############################################################################
# Lookup istio-ingressgateway service data
##############################################################################

data "kubernetes_service" "istio_ingressgateway" {
  depends_on = [null_resource.confirm_istio_operational]
  for_each   = toset(var.service_mesh_control_planes[*].namespace)

  metadata {
    name      = "istio-ingressgateway"
    namespace = each.key
  }
}

##############################################################################
# Ingress sub-domains
##############################################################################

locals {
  istio_ingressgateway = [for k in data.kubernetes_service.istio_ingressgateway : k]
}

module "ingress_subdomain" {
  source                        = "./ocp-service-mesh-dns-nlb"
  count                         = var.create_ingress_subdomains == true ? length(var.service_mesh_control_planes) : 0
  istio_control_plane_namespace = local.istio_ingressgateway[count.index].metadata[0].namespace
  ibmcloud_api_key              = var.ibmcloud_api_key
  cluster_id                    = var.cluster_id
  default_vpc_lb_host           = local.istio_ingressgateway[count.index].status[0].load_balancer[0].ingress[0].hostname
}
