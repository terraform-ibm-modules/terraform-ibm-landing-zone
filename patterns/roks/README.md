# Red Hat OpenShift Container Platform on VPC landing zone

![Architecture diagram of the OpenShift Container Platform on VPC deployable architecture](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/roks.drawio.svg)

This architecture supports the creation of a Red Hat OpenShift Container Platform on VPC landing zone in a single region architecture on IBM Cloud.

You can't update Red Hat OpenShift cluster nodes by using this variation. The Terraform logic ignores updates to prevent possible destructive changes. Update the cluster outside of the Terraform code.

:exclamation: **Important:** The controls `SC-13(0)`, `SC-28(0)` and `SC-28(1)(0)` can be met if Hyper Protect Crypto Service is used as the Key Management solution.
