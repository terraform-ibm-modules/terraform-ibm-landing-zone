# Add a VSI to a landing zone VPC

## Before you begin

- The block storage to KMS auth policy must exist before provisioning this DA. This policy would have been created by the VPC landing zone DA if the `add_kms_block_storage_s2s` option is set to true, which is set to `true` by default.

To deploy this architecture, you need the VPC ID, subnet names, and boot volume encryption key from your existing VPC landing zone deployable architecture. For information about finding the information, see [Adding a VSI to your VPC landing zone deployable architecture](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ext-with-vsi).

This extension DA can be provisioned ontop of the VPC landing zone DA, as well as the ROKS landing zone DA since both deploy an SLZ VPC.

This architecture creates a VSI in some or all of the subnets of your existing landing zone VPC deployable architecture.

![Architecture diagram for adding a VSI to your VPC landing zone deployable architecture](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/vsi-extension.drawio.svg)



