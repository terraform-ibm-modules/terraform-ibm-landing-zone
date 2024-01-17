# Override.json Example

This example demonstrates how to configure the landing zone module by using an `override.json` file. The example builds on the default topology that is defined in the VSI pattern and uses a JSON file to override the default configuration.

The example deploys the following infrastructure:

- An edge VPC with one VSI in one of the three subnets and a VPC load balancer in the edge VPC, exposing the VSI publicly.
- A jump server VSI in the management VPC, exposing a public floating IP address.

:exclamation: **Important:** This example demonstrates how to customize the topology with a JSON configuration file. The topology is not highly available or validated for the IBM Cloud Framework for Financial Services.
