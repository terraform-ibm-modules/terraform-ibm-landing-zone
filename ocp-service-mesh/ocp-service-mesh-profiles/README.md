# Service Mesh Profiles

This goal of this submodule is to provide a restricted list of predefined service mesh profiles for the most common deployment topologies across PaaS.
You pass the profiles as input to the
[ocp-service-mesh-module](../../ocp-service-mesh-module) as one element of the
[service_mesh_control_planes](../../README.md#input_service_mesh_control_planes)
list input.

The profiles in this module are control plane (infrastructure) profiles that are passed to the RedHat OpenShift Service Mesh operator. The profiles control the general service mesh topology, such as the placement and configuration of the egress and ingress gateways, the general service mesh configuration (examples include Mutual Transport Layer Security, and cipher suites). The profiles are not set to configure network paths (by using the Istio custom resource definition) that are required by applications. That configuration is planned separately.

Three predefined profiles are provided. As additional common patterns emerge across PaaS, the
module will be the place to consolidate and commonize common profiles for those patterns.

These profiles must go through compliance review before the module reaches GA status.

The module provides two levels of granularity:
- A set of control plane profiles that are functionally complete (for example, defining ingress, egress, and proxy config). Using the control plane profiles is the most common way to consume this module for services. For more information about the available profiles, see the [outputs](#outputs) section.
- A set of profiles for specific aspects of the service mesh (for example, proxy config and ingress gateway). You build a full Service Mesh control plane configuration based on these individual predefined configuration "blocks". This usage is for advanced users with specific needs that are not covered by the full control plane profiles. For more information, see the submodules in the [modules](#modules) section, and look at the `outputs.tf` file for a few examples.

## Usage

See [usage](../README.md#usage)

## Examples

- [Consuming public_ingress_egress_with_sdnlb_transit profile](../examples/alb-public-ingress-egress-with-sdnlb-transit)
- [Consuming public_ingress_egress_no_transit profile (using NLBs)](../examples/nlb-public-ingress-egress-no-transit)
- [Consuming public_ingress_egress_with_sdnlb_transit_cse_proxy_enabled profile](../examples/sdnlb-cse-proxy-existing-cluster)
- [Basic Example with Multiple Control Planes](../examples/multiple-control-planes)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_pilot_config"></a> [pilot\_config](#module\_pilot\_config) | ./pilot-runtime | n/a |
| <a name="module_proxy_config"></a> [proxy\_config](#module\_proxy\_config) | ./proxy | n/a |
| <a name="module_public_egress_config"></a> [public\_egress\_config](#module\_public\_egress\_config) | ./public-egress | n/a |
| <a name="module_public_ingress_config"></a> [public\_ingress\_config](#module\_public\_ingress\_config) | ./public-ingress | n/a |
| <a name="module_transit_egress_config"></a> [transit\_egress\_config](#module\_transit\_egress\_config) | ./transit-egress | n/a |
| <a name="module_transit_ingress_config"></a> [transit\_ingress\_config](#module\_transit\_ingress\_config) | ./transit-ingress | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_sdnlb_ports"></a> [additional\_sdnlb\_ports](#input\_additional\_sdnlb\_ports) | Optional list of additional ports to open on the sDNLB transit ingress gateway | `list(number)` | `[]` | no |
| <a name="input_control_plane_name"></a> [control\_plane\_name](#input\_control\_plane\_name) | The name to give the control plane. If left null, a default value will be used. | `string` | `null` | no |
| <a name="input_control_plane_namespace"></a> [control\_plane\_namespace](#input\_control\_plane\_namespace) | Service mesh control plane namespace | `string` | `"istio-system"` | no |
| <a name="input_enrolled_namespaces"></a> [enrolled\_namespaces](#input\_enrolled\_namespaces) | Application namespace to enroll into this service mesh control plane | `list(any)` | `[]` | no |
| <a name="input_vpc_lb_type"></a> [vpc\_lb\_type](#input\_vpc\_lb\_type) | VPC Load Balancer type to provision. Accepts: alb or nlb | `string` | `"alb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_basic_with_mtls"></a> [basic\_with\_mtls](#output\_basic\_with\_mtls) | NB: This profile is for very basic POCs and is not part of the compliance framework.<br>  Profile with:<br>  1. One INGRESS gateway deployment (consuming from public VPC LB)<br>    - No node selectors or tolerations so gateway pods assigned across all nodes (so ensure all nodes have public access)<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>  2. One EGRESS gateway deployment<br>    - No node selectors or tolerations so gateway pods assigned across all nodes (so ensure all nodes have public access)<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>  3. Access logging turned on<br>  4. mTLS enabled (data and control planes) |
| <a name="output_public_ingress_egress_no_transit"></a> [public\_ingress\_egress\_no\_transit](#output\_public\_ingress\_egress\_no\_transit) | Profile with:<br>  1. One public INGRESS gateway deployment (consuming from public VPC LB)<br>    - Gateway pods located on edge worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  2. One public EGRESS gateway deployment<br>    - Gateway pods located on edge worker pool (with public internet access through the public gateway).<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti affinity - eg: forcing pods to spread across workers<br>    - Egress allow-list enforced - egress allows only to endpoints configured as istio ServiceEntries<br>  3. Access logging turned on, JSON format<br>  4. mTLS enabled (data and control planes)<br>  5. Istio Pilot pods located on private worker pool |
| <a name="output_public_ingress_egress_with_sdnlb_transit"></a> [public\_ingress\_egress\_with\_sdnlb\_transit](#output\_public\_ingress\_egress\_with\_sdnlb\_transit) | Profile with:<br>  1. One public INGRESS gateway deployment (consuming from public VPC LB)<br>    - Gateway pods located on edge worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  2. One transit INGRESS gateway deployment (consuming from sDNLB)<br>    - Gateway pods located on transit worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  3. One public EGRESS gateway deployment<br>    - Gateway pods located on edge worker pool (with public internet access through the public gateway).<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti affinity - eg: forcing pods to spread across workers<br>    - Egress allow-list enforced - egress allows only to endpoints configured as istio ServiceEntries<br>  4. One transit EGRESS gateway deployment (to sit in front of the VPEs in transit)<br>    - Allows deep packet inspection if needed + gives further controls on what pods can make a call to what VPE IP<br>    - Gateway pods located on transit worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  5. Access logging turned on, JSON format<br>  6. mTLS enabled (data and control planes)<br>  7. Istio Pilot pods located on private worker pool |
| <a name="output_public_ingress_egress_with_sdnlb_transit_cse_proxy_enabled"></a> [public\_ingress\_egress\_with\_sdnlb\_transit\_cse\_proxy\_enabled](#output\_public\_ingress\_egress\_with\_sdnlb\_transit\_cse\_proxy\_enabled) | Profile with:<br>  1. One public INGRESS gateway deployment (consuming from public VPC LB)<br>    - Gateway pods located on edge worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  2. One transit INGRESS gateway deployment (consuming from sDNLB)<br>    - Gateway pods located on transit worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  3. One public EGRESS gateway deployment<br>    - Gateway pods located on edge worker pool (with public internet access through the public gateway).<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti affinity - eg: forcing pods to spread across workers<br>    - Egress allow-list enforced - egress allows only to endpoints configured as istio ServiceEntries<br>  4. One transit EGRESS gateway deployment (to sit in front of the VPEs in transit)<br>    - Allows deep packet inspection if needed + gives further controls on what pods can make a call to what VPE IP<br>    - Gateway pods located on transit worker pool<br>    - Auto-scaling enabled (min 3 -> max 10 replicas)<br>    - HA anti-affinity enabled - eg: forcing pods to spread across workers<br>  5. Configures CSE Proxy Envoy Filter<br>  6. Access logging turned on, JSON format<br>  7. mTLS enabled (data and control planes)<br>  8. Istio Pilot pods located on private worker pool |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
