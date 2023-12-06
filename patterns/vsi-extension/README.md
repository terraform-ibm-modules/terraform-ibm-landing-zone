# Add a VSI to a landing zone VPC

This architecture creates virtual server instances (VSI) for VPC in some or all of the subnets of any existing landing zone VPC deployable architecture.

## Before you begin

- You must have either the [VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vpc-9fc0fa64-27af-4fed-9dce-47b3640ba739-global) or [Red Hat OpenShift Container Platform on VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-ocp-95fccffc-ae3b-42df-b6d9-80be5914d852-global) deployable architecture deployed.
- The block storage to KMS auth policy must exist. This policy would have been created by one of the above deployable architectures if the `add_kms_block_storage_s2s` variable was set to `true`, which is default value.
- You need the VPC ID, subnet names, and boot volume encryption key from your existing landing zone VPC deployable architecture. For information about finding these values, see [Adding a VSI to your VPC landing zone deployable architecture](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ext-with-vsi).

![Architecture diagram for adding a VSI to your VPC landing zone deployable architecture](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/vsi-extension.drawio.svg)
