# IBM Secure Landing Zone for the VSI pattern

## Architecture diagram

![VSI pattern architecture diagram](../../reference-architectures/vsi-vsi.drawio.svg)

## Configured components and services

The following components are configured through automation:

* Resource groups
* KMS service
* Management access group
* Management KMS key
* Management Cloud Object Storage instance and Cloud Object Storage buckets
* Management Cloud Object Storage authorization for Hyper Protect Crypto Services
* Management Flow log, Flow log Cloud Object Storage buckets and authorization
* Management VPC
* Management VPC VSI
* Management VPC VSI encryption authorization
* Management VPC VSI SSH module
* Management Subnets for VSI, VPE, and VPN resources
* Management VPE gateway (for Cloud Object Storage)
* Workload access group
* Workload KMS key
* Workload Cloud Object Storage instance and Cloud Object Storage buckets
* Workload Cloud Object Storage authorization for Hyper Protect Crypto Services
* Workload Flow log, Flow log Cloud Object Storage buckets and authorization
* Workload VPC
* Workload VPC VSI
* Workload VPC VSI encryption authorization
* Workload VPC VSI SSH module
* Workload subnets for VPC VSI, VPE, and VPN resources
* Workload VPE gateway (for Cloud Object Storage)
* IBM Transit gateway
