# Dynamic Values

This module compiles various dynamic values for components in `../landing-zone`. These values are compiled here to allow for the unit testing of each of these complex functions only referencing variables.

## Unit Tests

Unit tests are created in [dynamic_values.unit_tests.tf](../dynamic_values.unit_tests.tf)

## Variable Notes

Since inputs are all strongly typed, to prevent any issues with adding module and resource values, variables in this module are not typed.

## Module Variables

Name                      | Description
------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
prefix                    | A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters.
region                    | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions.
vpc_modules               | Direct reference to VPC Modules
vpcs                      | Direct reference to vpcs variable
clusters                  | 
cos                       | Direct reference to cos variable
cos_data_source           | COS Data Resources
cos_resource              | Created COS instance resources
cos_resource_keys         | Create COS resource keys
security_groups           | Security groups variable
resource_groups           | Reference to compiled resource group locals
key_management            | Reference to key management variable
key_management_guid       | Key Management GUID
virtual_private_endpoints | Direct reference to Virtual Private Endpoints variable
vpn_gateways              | VPN Gateways Variable Value

## Module Outputs

Name                                        | Description
------------------------------------------- | --------------------------------------------------------------------------------
clusters_map                                | Cluster Map for dynamic cluster creation
worker_pools_map                            | Cluster worker pools map
cos_data_map                                | Map with key value pairs of name to instance if using data
cos_map                                     | Map with key value pairs of name to instance if not using data
cos_instance_ids                            | Instance map for cloud object storage instance IDs
cos_bucket_list                             | List of all COS buckets with instance name added
cos_bucket_map                              | Map including key of bucket names with bucket data as values
cos_keys_list                               | List of all COS keys
cos_key_map                                 | Map of COS keys
bucket_to_instance_map                      | Maps bucket names to instance ids and api keys
flow_logs_map                               | Map of flow logs instances to create
vpc_map                                     | VPC Map
security_group_map                          | Map of Security Group Components
security_group_rule_list                    | List of all security group rules
security_group_rules_map                    | Map of all security group rules
service_authorization_vpc_to_key_management | Service authorizations to allow server-protect to be encrypted by key management
service_authorization_cos_to_key_management | Service authorizations to allow cos bucket to be encrypted by key management
service_authorization_flow_logs_to_cos      | Service authorizations to allow flow logs to write in cos bucket
vpe_services                                | Map of VPE services to be created. Currently only COS is supported.
vpe_gateway_list                            | List of gateways to be created
vpe_gateway_map                             | Map of gateways to be created
vpe_subnet_reserved_ip_list                 | List of reserved subnet ips for vpes
vpe_subnet_reserved_ip_map                  | Map of reserved subnet ips for vpes
vpn_gateway_map                             | Map of VPN Gateways with VPC data
vpn_connection_list                         | List of VPN gateway connections
vpn_connection_map                          | Map of VPN gateway connections
bastion_template_data_map                   | Map of Bastion Host template data
bastion_vsi_map                             | Map of Bastion Host VSI deployments
bastion_template_data_list                  | Map of Bastion Host template data list
