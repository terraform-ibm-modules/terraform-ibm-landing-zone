
# Configuring Landing Zone with Account Base DA to create CBR VPC Zone

This tutorial provides step-by-step instructions for using the  IBM Cloud Account Infrastructure Base Deployment Architecture to provision a Context-Based Restriction (CBR) VPC zone and configure it with Landing Zone.

## Prerequisites

- IBM Cloud account with administrative permissions

## Step 1: Deploy the Account Infrastructure Base Deployment Architecture

1. Navigate to the IBM Cloud Catalog using this URL:
   [Cloud automation for account configuration](https://cloud.ibm.com/catalog/7a4d68b4-cf8b-40cd-a3d1-f49aff526eb3/architecture/deploy-arch-ibm-account-infra-base-63641cec-6093-4b4f-b7b0-98d2f4185cd6-global)

2. Click on **Add to project** to start the deployment process

3. Configure the deployment parameters:
   - Enter the name for the project
   - Enter the description (optional)
   - Enter the configuration name
   - Select the region
   - Select the resource group

4. Review your configuration and click **Create**

5. Configure the required variables present under **security**, **required** and **optional**

6. Deploy....

## Step 2: Retrieve the CBR VPC Zone ID

The CBR Zone ID is available as a Terraform output after the Account Base DA deployment completes.

