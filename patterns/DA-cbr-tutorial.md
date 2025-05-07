
# Configuring Landing Zone with Cloud automation for account configuration to create CBR VPC Zone

This tutorial provides step-by-step instructions for using the [Cloud automation for account configuration](https://cloud.ibm.com/catalog/7a4d68b4-cf8b-40cd-a3d1-f49aff526eb3/architecture/deploy-arch-ibm-account-infra-base-63641cec-6093-4b4f-b7b0-98d2f4185cd6-global?kind=terraform&format=terraform&version=93c7f855-881d-459b-8999-4567a4883f57-global) to provision a [Context-Based Restriction (CBR)](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis) VPC network [zone](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#network-zones-whatis) and to configure `existing_vpc_cbr_zone_id` to add VPCs created by [Red Hat OpenShift Container Platform on VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-ocp-95fccffc-ae3b-42df-b6d9-80be5914d852-global), a [VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vpc-9fc0fa64-27af-4fed-9dce-47b3640ba739-global), or a [VSI on VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vsi-ef663980-4c71-4fac-af4f-4a510a9bcf68-global) to the [CBR VPC network zone](https://cloud.ibm.com/docs/account?topic=account-context-restrictions-whatis#vpc-attribute). The Cloud automation for account configuration creates a predefined network zones (a zone for each [service](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/blob/main/modules/fscloud/README.md#input_zone_service_ref_list)) and a [VPC zone](https://github.com/terraform-ibm-modules/terraform-ibm-cbr/blob/main/modules/fscloud/README.md#input_zone_vpc_crn_list), and the objective of this tutorial is to add the VPCs created and managed by landing zone automation to the predefined [CBR VPC zone]((https://github.com/terraform-ibm-modules/terraform-ibm-cbr/blob/main/modules/fscloud/README.md#input_zone_vpc_crn_list)).

## Prerequisites
- The Editor role on the [Projects]((https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects)) service
- The Editor and Manager role on the [Schematics](https://cloud.ibm.com/docs/schematics) service
- The Viewer role on the resource group for the project

For more information, see [Assigning users access to projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-access-project).

## Step 1: Deploy the Cloud automation for account configuration

1. Navigate to the IBM Cloud Catalog using this URL:
   [Cloud automation for account configuration](https://cloud.ibm.com/catalog/7a4d68b4-cf8b-40cd-a3d1-f49aff526eb3/architecture/deploy-arch-ibm-account-infra-base-63641cec-6093-4b4f-b7b0-98d2f4185cd6-global?kind=terraform&format=terraform&version=93c7f855-881d-459b-8999-4567a4883f57-global)

2. Click on **Add to [project](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects)** to start the deployment process

3. Configure the deployment parameters:
   - Enter the name for the project
   - Enter the description (optional)
   - Enter the configuration name
   - Select the region
   - Select the resource group

4. Review your configuration and click **Create**

5. Configure the required variables present under **security**, **required** and **optional** sections.

6. Click on deploy.

## Step 2: Retrieve the CBR VPC Zone ID

To access the **CBR VPC Zone ID**, which becomes available as an output after the Account Base DA deployment completes -

1. Navigate to **Account Infrastructure Base** deployment and select the configuration as shown in the reference image below.

   ![Projects Account Infrastructure Base Deployment](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/infra-base-deployed.png)

2. In the **outputs** section, locate the output variable named `cbr_map_vpc_zoneid` and copy the `zone_id` value as illustrated below.

   ![Projects Account Infrastructure Base Deployment CBR Zone VPC ID Output](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/infra-base-cbr-vpc-zone-id.png)

## Step 3:  Configure Landing Zone with the CBR Zone ID

To properly configure landing zone with the retrieved CBR Zone ID -

1. Select the appropriate landing zone automation from one of the following options:
   - [Red Hat OpenShift Container Platform on VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-ocp-95fccffc-ae3b-42df-b6d9-80be5914d852-global)
   - [VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vpc-9fc0fa64-27af-4fed-9dce-47b3640ba739-global)
   - [VSI on VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vsi-ef663980-4c71-4fac-af4f-4a510a9bcf68-global)

2. Configure the required variables present under **security**, **required** and **optional** sections.

3. Within the **optional** section, locate the field labeled `existing_vpc_cbr_zone_id` and paste the `zone_id` value copied in step 2, as shown below.

   ![Adding CBR VPC Zone ID](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/existing_vpc_cbr_zone_id.png)

4. Click on deploy.

5. Once deployed, CBR VPC zone will contain the required VPCs IDs as shown below.

   ![CBR VPC zone containing required VPC IDs](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone/main/reference-architectures/cbr-vpc-zone.png)
