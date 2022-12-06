# No compute example

This example shows how you can use the landing zone module to create a networking infrastructure layer without any compute resources (no VSI, nor OpenShift cluster).

The example deploys all the network components and associated compliance services that are defined in the [mixed](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/tree/main/patterns/mixed) pattern, but does not deploy any compute resource (no VSI or any OpenShift cluster).

This example provides a base to a modular solution because you can use this network layer as a base on which the compute resources are deployed, possibly through separate Terraform modules.

Example usage:
```
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```
