# Landing Zone VSI Pattern

This template allows a user to create a landing zone

![vsi](../../reference-architectures/vsi-vsi.drawio.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.5 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.2.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamic_values"></a> [dynamic\_values](#module\_dynamic\_values) | ../dynamic_values | n/a |
| <a name="module_landing_zone"></a> [landing\_zone](#module\_landing\_zone) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_scc_posture_credential.credentials](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.49.0/docs/resources/scc_posture_credential) | resource |
| [external_external.format_output](https://registry.terraform.io/providers/hashicorp/external/2.2.3/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IC_SCHEMATICS_WORKSPACE_ID"></a> [IC\_SCHEMATICS\_WORKSPACE\_ID](#input\_IC\_SCHEMATICS\_WORKSPACE\_ID) | leave blank if running locally. This variable will be automatically populated if running from an IBM Cloud Schematics workspace | `string` | `""` | no |
| <a name="input_add_atracker_route"></a> [add\_atracker\_route](#input\_add\_atracker\_route) | Atracker can only have one route per zone. Use this value to disable or enable the creation of atracker route | `bool` | `true` | no |
| <a name="input_add_edge_vpc"></a> [add\_edge\_vpc](#input\_add\_edge\_vpc) | Create an edge VPC. This VPC will be dynamically added to the list of VPCs in `var.vpcs`. Conflicts with `create_f5_network_on_management_vpc` to prevent overlapping subnet CIDR blocks. | `bool` | `false` | no |
| <a name="input_add_kms_block_storage_s2s"></a> [add\_kms\_block\_storage\_s2s](#input\_add\_kms\_block\_storage\_s2s) | add kms to block storage s2s authorization | `bool` | `true` | no |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | The terraform application id for phone\_home\_url\_metadata | `string` | `"null"` | no |
| <a name="input_appid_name"></a> [appid\_name](#input\_appid\_name) | Name of appid instance. | `string` | `"appid"` | no |
| <a name="input_appid_resource_group"></a> [appid\_resource\_group](#input\_appid\_resource\_group) | Resource group for existing appid instance. This value is ignored if a new instance is created. | `string` | `null` | no |
| <a name="input_as3_declaration_url"></a> [as3\_declaration\_url](#input\_as3\_declaration\_url) | URL to fetch the f5-appsvcs-extension declaration | `string` | `"null"` | no |
| <a name="input_byol_license_basekey"></a> [byol\_license\_basekey](#input\_byol\_license\_basekey) | Bring your own license registration key for the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_create_f5_network_on_management_vpc"></a> [create\_f5\_network\_on\_management\_vpc](#input\_create\_f5\_network\_on\_management\_vpc) | Set up bastion on management VPC. This value conflicts with `add_edge_vpc` to prevent overlapping subnet CIDR blocks. | `bool` | `false` | no |
| <a name="input_create_secrets_manager"></a> [create\_secrets\_manager](#input\_create\_secrets\_manager) | Create a secrets manager deployment. | `bool` | `false` | no |
| <a name="input_do_declaration_url"></a> [do\_declaration\_url](#input\_do\_declaration\_url) | URL to fetch the f5-declarative-onboarding declaration | `string` | `"null"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The F5 BIG-IP domain name | `string` | `"local"` | no |
| <a name="input_enable_f5_external_fip"></a> [enable\_f5\_external\_fip](#input\_enable\_f5\_external\_fip) | Enable F5 external interface floating IP. Conflicts with `enable_f5_management_fip`, VSI can only have one floating IP per instance. | `bool` | `false` | no |
| <a name="input_enable_f5_management_fip"></a> [enable\_f5\_management\_fip](#input\_enable\_f5\_management\_fip) | Enable F5 management interface floating IP. Conflicts with `enable_f5_external_fip`, VSI can only have one floating IP per instance. | `bool` | `false` | no |
| <a name="input_enable_scc"></a> [enable\_scc](#input\_enable\_scc) | Enable creation of SCC resources | `bool` | `false` | no |
| <a name="input_enable_transit_gateway"></a> [enable\_transit\_gateway](#input\_enable\_transit\_gateway) | Create transit gateway | `bool` | `true` | no |
| <a name="input_f5_image_name"></a> [f5\_image\_name](#input\_f5\_image\_name) | Image name for f5 deployments. Must be null or one of `f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`,`f5-bigip-16-1-3-2-0-0-4-ltm-1slot`,`f5-bigip-16-1-3-2-0-0-4-all-1slot`,`f5-bigip-17-0-0-1-0-0-4-ltm-1slot`,`f5-bigip-17-0-0-1-0-0-4-all-1slot`]. | `string` | `"f5-bigip-17-0-0-1-0-0-4-all-1slot"` | no |
| <a name="input_f5_instance_profile"></a> [f5\_instance\_profile](#input\_f5\_instance\_profile) | F5 vsi instance profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles. | `string` | `"cx2-4x8"` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | The F5 BIG-IP hostname | `string` | `"f5-ve-01"` | no |
| <a name="input_hs_crypto_instance_name"></a> [hs\_crypto\_instance\_name](#input\_hs\_crypto\_instance\_name) | Optionally, you can bring you own Hyper Protect Crypto Service instance for key management. If you would like to use that instance, add the name here. Otherwise, leave as null | `string` | `null` | no |
| <a name="input_hs_crypto_resource_group"></a> [hs\_crypto\_resource\_group](#input\_hs\_crypto\_resource\_group) | If you're using Hyper Protect Crypto services in a resource group other than `Default`, provide the name here. | `string` | `null` | no |
| <a name="input_https_cert"></a> [https\_cert](#input\_https\_cert) | The https certificate used by bastion host for teleport | `string` | `null` | no |
| <a name="input_https_key"></a> [https\_key](#input\_https\_key) | The https private key used by bastion host for teleport | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_license_host"></a> [license\_host](#input\_license\_host) | BIGIQ IP or hostname to use for pool based licensing of the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_license_password"></a> [license\_password](#input\_license\_password) | BIGIQ password to use for the pool based licensing of the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_license_pool"></a> [license\_pool](#input\_license\_pool) | BIGIQ license pool name of the pool based licensing of the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_license_sku_keyword_1"></a> [license\_sku\_keyword\_1](#input\_license\_sku\_keyword\_1) | BIGIQ primary SKU for ELA utility licensing of the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_license_sku_keyword_2"></a> [license\_sku\_keyword\_2](#input\_license\_sku\_keyword\_2) | BIGIQ secondary SKU for ELA utility licensing of the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | How to license, may be 'none','byol','regkeypool','utilitypool' | `string` | `"none"` | no |
| <a name="input_license_unit_of_measure"></a> [license\_unit\_of\_measure](#input\_license\_unit\_of\_measure) | BIGIQ utility pool unit of measurement | `string` | `"hourly"` | no |
| <a name="input_license_username"></a> [license\_username](#input\_license\_username) | BIGIQ username to use for the pool based licensing of the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_message_of_the_day"></a> [message\_of\_the\_day](#input\_message\_of\_the\_day) | Banner message that is exposed to the user at authentication time | `string` | `null` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning. | `string` | `"10.0.0.0/8"` | no |
| <a name="input_override"></a> [override](#input\_override) | Override default values with custom JSON template. This uses the file `override.json` to allow users to create a fully customized environment. | `bool` | `false` | no |
| <a name="input_override_json_string"></a> [override\_json\_string](#input\_override\_json\_string) | Override default values with custom JSON. Any value here other than an empty string will override all other configuration changes. | `string` | `""` | no |
| <a name="input_phone_home_url"></a> [phone\_home\_url](#input\_phone\_home\_url) | The URL to POST status when BIG-IP is finished onboarding | `string` | `"null"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_provision_teleport_in_f5"></a> [provision\_teleport\_in\_f5](#input\_provision\_teleport\_in\_f5) | Provision teleport VSI in `bastion` subnet tier of F5 network if able. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions. | `string` | n/a | yes |
| <a name="input_scc_collector_description"></a> [scc\_collector\_description](#input\_scc\_collector\_description) | Description of SCC Collector | `string` | `"collector description"` | no |
| <a name="input_scc_cred_description"></a> [scc\_cred\_description](#input\_scc\_cred\_description) | Description of SCC Credential | `string` | `"This credential is used for SCC."` | no |
| <a name="input_scc_cred_name"></a> [scc\_cred\_name](#input\_scc\_cred\_name) | The name of the credential | `string` | `"slz-cred"` | no |
| <a name="input_scc_scope_description"></a> [scc\_scope\_description](#input\_scc\_scope\_description) | Description of SCC Scope | `string` | `"IBM-schema-for-configuration-collection"` | no |
| <a name="input_scc_scope_name"></a> [scc\_scope\_name](#input\_scc\_scope\_name) | The name of the SCC Scope | `string` | `"scope"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_teleport_admin_email"></a> [teleport\_admin\_email](#input\_teleport\_admin\_email) | Email for teleport vsi admin. | `string` | `null` | no |
| <a name="input_teleport_domain"></a> [teleport\_domain](#input\_teleport\_domain) | The domain of the bastion host | `string` | `null` | no |
| <a name="input_teleport_hostname"></a> [teleport\_hostname](#input\_teleport\_hostname) | The name of the instance or bastion host | `string` | `null` | no |
| <a name="input_teleport_instance_profile"></a> [teleport\_instance\_profile](#input\_teleport\_instance\_profile) | Machine type for Teleport VSI instances. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles. | `string` | `"cx2-4x8"` | no |
| <a name="input_teleport_license"></a> [teleport\_license](#input\_teleport\_license) | The contents of the PEM license file | `string` | `null` | no |
| <a name="input_teleport_management_zones"></a> [teleport\_management\_zones](#input\_teleport\_management\_zones) | Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value. | `number` | `0` | no |
| <a name="input_teleport_version"></a> [teleport\_version](#input\_teleport\_version) | Version of Teleport Enterprise to use | `string` | `"7.1.0"` | no |
| <a name="input_teleport_vsi_image_name"></a> [teleport\_vsi\_image\_name](#input\_teleport\_vsi\_image\_name) | Teleport VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images. | `string` | `"ibm-ubuntu-18-04-6-minimal-amd64-2"` | no |
| <a name="input_template_source"></a> [template\_source](#input\_template\_source) | The terraform template source for phone\_home\_url\_metadata | `string` | `"f5devcentral/ibmcloud_schematics_bigip_multinic_declared"` | no |
| <a name="input_template_version"></a> [template\_version](#input\_template\_version) | The terraform template version for phone\_home\_url\_metadata | `string` | `"20210201"` | no |
| <a name="input_tgactive_url"></a> [tgactive\_url](#input\_tgactive\_url) | The URL to POST L3 addresses when tgactive is triggered | `string` | `""` | no |
| <a name="input_tgrefresh_url"></a> [tgrefresh\_url](#input\_tgrefresh\_url) | The URL to POST L3 addresses when tgrefresh is triggered | `string` | `"null"` | no |
| <a name="input_tgstandby_url"></a> [tgstandby\_url](#input\_tgstandby\_url) | The URL to POST L3 addresses when tgstandby is triggered | `string` | `"null"` | no |
| <a name="input_tmos_admin_password"></a> [tmos\_admin\_password](#input\_tmos\_admin\_password) | admin account password for the F5 BIG-IP instance | `string` | `null` | no |
| <a name="input_ts_declaration_url"></a> [ts\_declaration\_url](#input\_ts\_declaration\_url) | URL to fetch the f5-telemetry-streaming declaration | `string` | `"null"` | no |
| <a name="input_use_existing_appid"></a> [use\_existing\_appid](#input\_use\_existing\_appid) | Use an existing appid instance. If this is false, one will be automatically created. | `bool` | `false` | no |
| <a name="input_use_random_cos_suffix"></a> [use\_random\_cos\_suffix](#input\_use\_random\_cos\_suffix) | Add a random 8 character string to the end of each cos instance, bucket, and key. | `bool` | `true` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. VPC names must begin with a lowercase letter and end with a lowercase letter or number. | `list(string)` | <pre>[<br>  "management",<br>  "workload"<br>]</pre> | no |
| <a name="input_vpn_firewall_type"></a> [vpn\_firewall\_type](#input\_vpn\_firewall\_type) | Bastion type if provisioning bastion. Can be `full-tunnel`, `waf`, or `vpn-and-waf`. | `string` | `null` | no |
| <a name="input_vsi_image_name"></a> [vsi\_image\_name](#input\_vsi\_image\_name) | VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images. | `string` | `"ibm-ubuntu-18-04-6-minimal-amd64-2"` | no |
| <a name="input_vsi_instance_profile"></a> [vsi\_instance\_profile](#input\_vsi\_instance\_profile) | VSI image profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles. | `string` | `"cx2-4x8"` | no |
| <a name="input_vsi_per_subnet"></a> [vsi\_per\_subnet](#input\_vsi\_per\_subnet) | Number of Virtual Servers to create on each VSI subnet. | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_config"></a> [config](#output\_config) | Output configuration as encoded JSON |
| <a name="output_fip_vsi"></a> [fip\_vsi](#output\_fip\_vsi) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. This list only contains instances with a floating IP attached. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources |
| <a name="output_schematics_workspace_id"></a> [schematics\_workspace\_id](#output\_schematics\_workspace\_id) | ID of the IBM Cloud Schematics workspace. Returns null if not ran in Schematics |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Using override.json

To create a fully customized environment based on the starting template, users can use [override.json](./override.json) by setting the template `override` variable to `true`.

### Variable Definitions

By using the variable definitions found in our [landing zone module](../../../terraform-ibm-landing-zone) any number and custom configuration of VPC components, VSI workoads, and clusters can be created. Currently `override.json` is set to contain the default environment configuration.

### Getting Your Environment

This module outputs `config`, a JSON encoded definition of your environment based on the defaults for Landing Zone and any variables changed using `override.json`. By using this output, it's easy to configure multiple additional workloads, VPCs, or subnets in existing VPCs to the default environment.

### Overriding Only Some Variables

`override.json` does not need to contain all elements. As an example override.json could be:
```json
{
    "enable_transit_gateway": false
}
```

In this use case, each other value would be the default configuration, just with a transit gateway disabled.
