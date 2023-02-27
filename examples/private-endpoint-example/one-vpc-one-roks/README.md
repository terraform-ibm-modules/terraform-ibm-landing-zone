# One VSI with one ROKS

This example demonstrates how to configure the landing zone module by using an `override.json` file. The example builds on the default topology that is defined in the roks pattern, and uses a JSON file to override the default configuration.

The example deploys the following infrastructure:

- A ROKS server in the workload VPC configured with observability agents.

:exclamation: **Important:** This example shows an example of basic topology. The topology is not highly available or validated for the IBM Cloud Framework for Financial Services.

Example usage:
```
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=region=eu-gb -var=prefix=my_slz
```
