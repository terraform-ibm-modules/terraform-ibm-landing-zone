# Override.json example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=landing-zone-override-example-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/tree/main/examples/override-example">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

This example demonstrates how to configure the landing zone module by using an `override.json` file. The example builds on the default topology that is defined in the VSI pattern, and uses a JSON file to override the default configuration.

:information_source: **Tip:** You can use the [landing zone configuration tool](https://terraform-ibm-modules.github.io/landing-zone-config-tool/#/home) to further customize the `override.json` file.

The example deploys the following infrastructure:

- An edge VPC with 1 VSI in one of the three subnets and a VPC load balancer in the edge VPC, exposing the VSI publicly.
- Deploys identical clusters across the VSI subnet tier in each VPC
- A jump server VSI in the management VPC, exposing a public floating IP address.

:exclamation: **Important:** This example shows how to customize the topology with a JSON configuration file. The topology is not highly available or validated for the IBM Cloud Framework for Financial Services.
