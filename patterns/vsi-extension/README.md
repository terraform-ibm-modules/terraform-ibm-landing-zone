# Add a VSI to a landing zone VPC

This architecture creates virtual server instances (VSI) for VPC in some or all of the subnets of any existing landing zone VPC deployable architecture.

NOTE: This solution only supports creating a VSI in a single VPC. If you wish to create VSIs in multiple VPCs you must create one instance of the solution per VPC.

## Before you begin

- You must have either the [VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vpc-9fc0fa64-27af-4fed-9dce-47b3640ba739-global) or [Red Hat OpenShift Container Platform on VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-ocp-95fccffc-ae3b-42df-b6d9-80be5914d852-global) deployable architecture deployed.
- You need an authorization policy that grants access between block storage and the KMS. The policy exists if you set the `add_kms_block_storage_s2s` input variable to `true` (the default value) in your existing landing zone deployable architecture.
- You need the VPC ID, subnet names, and boot volume encryption key from your existing landing zone deployable architecture. For information about finding these values, see [Adding a VSI to your VPC landing zone deployable architecture](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ext-with-vsi).

![Architecture diagram for adding a VSI to your VPC landing zone deployable architecture](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/vsi-extension.drawio.svg)
