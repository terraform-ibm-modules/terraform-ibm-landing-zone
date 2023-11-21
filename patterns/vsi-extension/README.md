# Add a VSI to a landing zone VPC

This logic creates a VSI to an existing landing zone VPC.

This code creates and configures the following infrastructure:
- Adds an SSH key to IBM Cloud or uses an existing one.
- Adds a VSI in each subnet of the landing zone VPC.

There are two ways through which a user can pass the VPC details for deploying the VSI, both the approaches are mutually exclusive.

## Using `vpc_id`

The VPC ID of the landing zone VPC can be assigned to the variable vpc_id in order to create a VSI within that specific VPC.

## Using `prerequisite_workspace_id` and `existing_vpc_name`

The user can specify the workspace ID associated with the deployment of the landing zone VPC when creating a new VSI.

Follow these steps to get the schematics workspace ID.

1. Click the Navigation menu icon, and then click Schematics > Workspaces.
1. Select the Workspace that is associated with landing zone VPC.
1. Click the Settings.
1. In the Details section, you can find the Workspace ID.

Pass the Workspace ID to the `prerequisite_workspace_id` variable and pass the name of the VPC to the `existing_vpc_name` to choosse the name of the VPC to which the user wants to deploy the VSI.
Please provide the Workspace ID for the prerequisite workspace and the name of the existing VPC to the `prerequisite_workspace_id` and `existing_vpc_name` variables respectively, to identify the VPC where you want to deploy the VSI.

Optional, user can pass the name of the key to the `existing_boot_volume_encryption_key_name` variable to be used for boot volume encryption from the list of keys fetched from the workspace.
