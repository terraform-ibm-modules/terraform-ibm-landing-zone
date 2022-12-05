# No compute example

This example shows how the landing-zone module can be used to create a networking infrastructure layer, without any compute resource (no VSI, nor OpenShift cluster).

This example deploys all of the network components and associated compliance services defined in the [mixed](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/tree/main/patterns/mixed) pattern - but does not deploy ANY compute resource (no VSI, nor any OpenShift cluster).

This network layer can be used as a base upon which compute resources are deployed, possibly through separate terraform modules. As such, this examples provides a base to a modular solution.

Example usage:
```
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```
