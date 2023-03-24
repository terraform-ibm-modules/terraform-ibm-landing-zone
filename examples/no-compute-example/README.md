# VPC landing zone (No compute example)

![vpc](../../reference-architectures/vpc.drawio.svg)

- This example shows how you can use the landing zone module to create a networking infrastructure layer without any compute resources (no VSI, nor OpenShift cluster).
- This example provides a base to a modular solution because you can use this network layer as a base on which the compute resources are deployed, possibly through separate Terraform modules.
