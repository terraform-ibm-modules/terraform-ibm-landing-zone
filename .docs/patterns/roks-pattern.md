# IBM Secure Landing Zone for the IBM Cloud Red Hat OpenShift Kubernetes pattern

## Architecture diagram

![ROKS pattern architecture diagram](../images/patterns/roks-pattern.png)

## Configured components and services

The following components are configured through automation:

* Resource groups
* KMS service
* Management access group
* Management KMS key
* Management Cloud Object Storage instance and Cloud Object Storage buckets
* Management Cloud Object Storage authorization for KMS
* Management flow log, Flow log Cloud Object Storage buckets and authorization
* Management VPC
* Management OpenShift Container Platform cluster
* Management VPC Kubernetes encryption authorization
* Management subnets for OpenShift Container Platform cluster, VPE, and VPN resources
* Management VPE gateway (for Cloud Object Storage)
* Management VPE gateway (for Container Registry)
* Workload access group
* Workload KMS key
* Workload Cloud Object Storage instance and Cloud Object Storage buckets
* Workload Cloud Object Storage authorization for KMS
* Workload Flow log, Flow log Cloud Object Storage buckets and authorization
* Workload VPC
* Workload OpenShift Container Platform cluster
* Workload VPC Kubernetes encryption authorization
* Workload subnets for VPC OpenShift Container Platform Cluster, VPE, and VPN resources
* Workload VPE gateway (for Cloud Object Storage)
* Workload VPE gateway (for Container Registry)
* IBM transit gateway
