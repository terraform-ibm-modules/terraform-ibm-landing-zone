# One VPC with one VSI example

The examples shows how you can use the landing zone module to create a basic, minimal topology by using an `override.json` file.

:information_source: **Tip:** You can use the [landing zone configuration tool](https://terraform-ibm-modules.github.io/landing-zone-config-tool/#/home) to further customize the `override.json` file.

The example deploys the following infrastructure:

- A single VPC that is named `management` with 3 subnets across the three availability zone to host VSIs. By default, the network ACLS are open.
- A single VSI that is name `jump-box` and located in one of the `vsi` subnets of the VPC. It is publicly exposed with a floating IP address and with open security groups.

The example also creates the minimum encryption and audit infrastructure:

- A Key Protect instance and key that is used to encrypt the VSI boot volume.
- The Activity Tracker infrastructure: An Activity Tracker route to an encrypted COS bucket that stores audit events.

:exclamation: **Important:** This example shows an example of basic topology. The topology is not highly available or validated for the IBM Cloud Framework for Financial Services.

Example usage:

```sh
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```
