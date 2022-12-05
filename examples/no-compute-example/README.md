# No compute example

This example shows how the landing-zone module can be used to create the networking infrastructure (VPC) without any compute resource (no VSI, nor OpenShift cluster).

This example can be used as a starting point where landing-zone lays out the network layers, and where other modules deploy compute resources on top of it.

This examples creates one single VPC:
  - Named "management" in this example
  - With 3 subnets across the 3 availability zone to host VSIs
  - Default, open network ACLs

This example also create the minimum encryption and audit infrastructure:
- Key protect instance and key used to encrypted the VSI boot volume
- Activity Tracker infrastructure (activity tracker route to an encrypted COS bucket storing audit events)

Example usage:
```
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```
