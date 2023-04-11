# VPC landing zone (No compute pattern)

![vpc](../../reference-architectures/vpc.drawio.svg)

- This pattern creates a networking infrastructure layer without any compute resources (no VSI, nor OpenShift cluster).
- This pattern provides a base to a modular solution because you can use this network layer as a base on which the compute resources are deployed, possibly through separate Terraform modules.
