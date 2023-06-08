# No compute architecture VPC landing zone

![Architecture diagram for the no compute pattern on VPC landing zone](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/vpc.drawio.svg)

This architecture deploys a simple IBM Cloud VPC infrastructure without any compute resources like Virtual Server Instances (VSIs) or Red Hat OpenShift clusters.

The architecture is a modular solution because you can use this architecture as a base on which to deploy compute resources. You can also deploy those resources by using the other landing zone deployable architectures or Terraform modules.

:exclamation: **Important:** The controls `SC-13(0)`, `SC-28(0)` and `SC-28(1)(0)` are only met if Hyper Protect Crypto Service is used as the Key Management solution.
