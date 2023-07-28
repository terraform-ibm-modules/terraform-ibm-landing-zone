# QuickStart VSI on VPC landing zone

## Architecture diagram

![QuickStart VSI on VPC pattern architecture diagram](../../reference-architectures/vsi-quickstart.drawio.svg)

## Configured components and services

The following components are configured through automation:

* Resource groups
* KMS service
* Management access group
* Management KMS key
* Management VPC
* Management VPC VSI
* Management VPC VSI encryption authorization
* Management VPC VSI SSH module
* Management Subnets for VSI, VPE, and VPN resources
* Workload access group
* Workload KMS key
* Workload VPC
* Workload VPC VSI
* Workload VPC VSI encryption authorization
* Workload VPC VSI SSH module
* Workload subnets for VPC VSI, VPE, and VPN resources
* IBM Transit gateway
