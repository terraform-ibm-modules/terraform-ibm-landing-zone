# Quickstart Example

This quickstart example will:

1. Deploy an edge VPC with 3 subnets with:
   - 1 VSI in one of the 3 subnet
   - A VPC Loadbalancer in the edge vpc, exposing publically the VSI.
2. Deploy a 'jump-box' VSI in the management VPC, exposing a public floating IP.

:exclamation: This is a quickstart example. The resulting topology is not HA, nor FS-Cloud compliant.
