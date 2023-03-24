# No compute example

![vpc](../../reference-architectures/vpc.drawio.svg)

This example shows how you can use the landing zone module to create a networking infrastructure layer without any compute resources (no VSI, nor OpenShift cluster).

The example deploys all the network components and associated compliance services that are defined in the [mixed](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/tree/main/patterns/mixed) pattern, but does not deploy any compute resource (no VSI or any OpenShift cluster).

This example provides a base to a modular solution because you can use this network layer as a base on which the compute resources are deployed, possibly through separate Terraform modules.

Example usage:
```bash
export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, <=1.4 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | ../../patterns/mixed | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | `"no-compute"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions. | `string` | `"us-south"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | Public SSH Key for VSI creation. Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_landing_zone"></a> [landing\_zone](#output\_landing\_zone) | Landing zone configuration |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
