# Add a VSI to a landing zone VPC

This logic creates a VSI to an existing landing zone VPC.

This code creates and configures the following infrastructure:
- Adds an SSH key to IBM Cloud or uses an existing one.
- Adds a VSI in each subnet of the landing zone VPC.


# Fetch vpc_id
You can get the vpc_id using the following ways:
1. Projects
    - Click the **Navigation menu** icon ![Navigation menu icon](../icons/icon_hamburger.svg "Menu"), and then click **Projects**.
    - Select the project associated with `VPC landing zone`.
    - In the Configurations section, choose the deployable architecture.
    - In the Outputs section, you can find a value with the name `vpc_data`.
    - `vpc_data` is a list of objects which contains all the vpc details. Select the `vpc_id` of the VPC on which you need to deploy the VSI.

2. UI
    - Click the **Navigation menu** icon ![Navigation menu icon](../icons/icon_hamburger.svg "Menu"), and then click **VPC Infrastructure** > **VPCs** from the **Network** section.
    - Select the VPC associated with the `VPC landing zone`, to which you wish to deploy the VSI.
    - In the **Virtual private cloud details** section, you can find the `VPC ID`.


# Fetch boot_volume_encryption_key
You can get the vpc_id using the following ways:
1. Projects
    - Click the **Navigation menu** icon ![Navigation menu icon](../icons/icon_hamburger.svg "Menu"), and then click **Projects**.
    - Select the project associated with `VPC landing zone`.
    - In the Configurations section, choose the deployable architecture.
    - In the Outputs section, you can find a value with the name `key_map`.
    - `key_map` is a list of objects which contains all the key details. Select the `crn` of the key to be used as `boot_volume_encryption_key`.

1. API
https://cloud.ibm.com/docs/key-protect?topic=key-protect-retrieve-key

# Fetch subnet_names
You can get the vpc_id using the following ways:
1. Projects
    - Click the **Navigation menu** icon ![Navigation menu icon](../icons/icon_hamburger.svg "Menu"), and then click **Projects**.
    - Select the project associated with `VPC landing zone`.
    - In the Configurations section, choose the deployable architecture.
    - In the Outputs section, you can find a value with the name `subnet_data`.
    - `subnet` is a list of objects which contains all the subnet details. Select the `name` of the subnets to whch you wish to deploy the VSI.
