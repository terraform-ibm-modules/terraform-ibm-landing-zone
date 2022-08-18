# Override.json Example

This example demonstrates how to pass configuration to the land-zone module through an `override.json` file.

The example builds on top of the default topology defined in the VSI pattern, and use a json file to 'override' the default configuration. Notably, to:
1. Deploy an edge VPC with 3 subnets with:
   - 1 VSI in one of the 3 subnet
   - A VPC Loadbalancer in the edge vpc, exposing publically the VSI.
2. Deploy a 'jump-box' VSI in the management VPC, exposing a public floating IP.

:exclamation: This example is for illustration purpose to show how to extensively customize the topology through a json configuration file. The resulting topology is not HA, nor FS-Cloud compliant.
