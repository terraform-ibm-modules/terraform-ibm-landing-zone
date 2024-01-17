# One VPC with one VSI Example

The example demonstrates how to use the landing zone module to create a basic, minimal topology by utilizing an `override.json` file.
1. A single VPC:
	* Named `management` in this example
	* Comprises three subnets across three availability zones to host VSIs
	* Default, open network ACLs
2. One single VSI:
	* Named 'jump-box' in this example
	* Located in one of the 'vsi' subnets of the VPC
	* Publicly exposed via a floating IP address
	* Open security groups

This example also creates the minimum encryption and audit infrastructure:
- A Key Protect instance and key that is used to encrypt the VSI boot volume
- The Activity Tracker infrastructure (Activity Tracker route to an encrypted COS bucket that stores audit events)

:exclamation: **Important:** This example shows a basic topology. The topology is not highly available or validated for the IBM Cloud Framework for Financial Services.

Example usage:
```
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```
