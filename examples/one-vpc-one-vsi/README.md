# One VPC with one VSI example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=landing-zone-one-vpc-one-vsi-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/tree/main/examples/one-vpc-one-vsi"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


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

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
