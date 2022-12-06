# One VPC with one VSI

You can use this example as a starting point to add capabilities incrementally. For example, adding features as part of a proof of concept.

The examples shows how you can use the landing zone module to create a basic, minimal topology by using an `override.json` file.
1. A single VPC:
   - Named `management` in this example
   - Includes three subnets across the three availability zone to host VSIs
   - Default, open network ACLs
2. One single VSI:
   - Named 'jump-box' in this example
   - Located in one of the 'vsi' subnets of the VPC
   - Publicly exposed via a floating IP address.
   - Open security groups

This example also create the minimum encryption and audit infrastructure:
- Key protect instance and key used to encrypted the VSI boot volume
- Activity Tracker infrastructure (activity tracker route to an encrypted COS bucket storing audit events)

:exclamation: **Important:** This example shows an example of basic topology. The topology is not highly available or validated for the IBM Cloud Framework for Financial Services.

Example usage:
```
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```
