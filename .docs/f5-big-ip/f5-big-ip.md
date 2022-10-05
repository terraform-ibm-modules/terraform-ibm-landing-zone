# Provisioning a F5 BIG-IP host using Secure Landing Zone

Through Secure Landing Zone, users can optionally provision the F5 BIG-IP so that one can setup the implemented solution of a client-to-site VPN and/or web application firewall (WAF) which is described [here](https://cloud.ibm.com/docs/allowlist/framework-financial-services?topic=framework-financial-services-vpc-architecture-connectivity-f5-tutorial)

## Prerequisites

You need the following items to deploy and configure the reference architecture above with an instance of BIG-IP:

1. F5 BIG-IP Virtual Edition license.
2. Additional IAM VPC Infrastructure Service service access of `IP Spoofing operator`
3. [Contact support](https://cloud.ibm.com/unifiedsupport/cases/form) to increase the quota for subnets per VPC.  The below chart shows the number of subnets needed dependent on the F5 BIG-IP deployment but it is best to ask for 30 subnets per VPC.  The chart below notes the CIDR blocks and the zones that each type is deployed.  Additional subnets for VPE's are also provisioned along with bastion host if that is used.

   Chart showing the subnets when provisioned on the Edge VPC
   | CIDRs        | Zone        | WAF    | Full-tunnel    | VPN-and-WAF    |
   | ------------ | ----------- | :----: | :------------: | :------------: |
   | 10.5.10.0/24 | zone-1      | X      | X              | X              |
   | 10.5.20.0/24 | zone-1      | X      | X              | X              |
   | 10.5.30.0/24 | zone-1      | X      | X              | X              |
   | 10.5.40.0/24 | zone-1      |        | X              | X              |
   | 10.5.50.0/24 | zone-1      |        | X              | X              |
   | 10.5.60.0/24 | zone-1      |        |                | X              |
   | 10.6.10.0/24 | zone-2      | X      | X              | X              |
   | 10.6.20.0/24 | zone-2      | X      | X              | X              |
   | 10.6.30.0/24 | zone-2      | X      | X              | X              |
   | 10.6.40.0/24 | zone-2      |        | X              | X              |
   | 10.6.50.0/24 | zone-2      |        | X              | X              |
   | 10.6.60.0/24 | zone-2      |        |                | X              |
   | 10.7.10.0/24 | zone-3      | X      | X              | X              |
   | 10.7.20.0/24 | zone-3      | X      | X              | X              |
   | 10.7.30.0/24 | zone-3      | X      | X              | X              |
   | 10.7.40.0/24 | zone-3      |        | X              | X              |
   | 10.7.50.0/24 | zone-3      |        | X              | X              |
   | 10.7.60.0/24 | zone-3      |        |                | X              |


   Chart showing the number of total subnets needed for the F5 BIG-IP and other services (VPE) within the VPC.  Includes VPE's
   | Service     | # of subnets without bastion | # of subnets with bastion |
   | ----------- | ---------------------------- | ------------------------- |
   | VPN and WAF | 21                           | 24                        |
   | Full-tunnel | 18                           | 21
   | WAF         | 15                           | 18


## Provision with Secure Landing Zone

The F5 BIG-IP can be provisioned in the Management or Edge/Transit VPC. It is best practice to place the F5 BIG-IP in the Edge/Transit VPC.  By default, it will provision an F5 BIG-IP within each zone of the region.  You can change this by utilizing [override.json](../../README.md#using-overridejson).

| Management VPC                               | Edge/Transit VPC              |
| -------------------------------------------- | ----------------------------- |
| ![management](../images/f5-management.png)   | ![edge](../images/edge-f5.png)|

### F5 BIG-IP configuration variables

In the terraform.tfvars file, there are several varibles that you can adjust. Some of the variables are optional but there are several that are needed to provision the F5 BIG-IP.  The important include:

```
add_edge_vpc                        # Automatically adds the edge/transit VPC along with the F5 BIG-IP
create_f5_network_on_management_vpc # Provision the F5 BIG-IP in the managment VPC
provision_teleport_on_f5            # Provision Teleport bastion hosts within the edge VPC.  See bastion documentation for more information about bastion hosts
vpn_firewall_type                   # The type of service you are using the BIG-IP for (full-tunnel, waf, vpn-and-waf).  This is required if you enable the F5 BIG-IP
hostname                            # Hostname of the F5 BIG-IP
domain                              # The domain name of the F5 BIG-IP
tmos_admin_password                 # The admin password to log into the management console (Requirements: Minimum length of 15 characters/Required Characters: Numeric = 1, Uppercase = 1, Lowercase = 1)
enable_f5_external_fip              # Enable a FIP on the external interface.  Default is true
enable_f5_management_fip            # Enable a FIP on the management interface.  Default is false
```

The below example show how to provision an F5 with the following:
 - Create an Edge/Transit VPC
 - Provision an F5 BIG-IP with the architecture setup for WAF in each zone
 - Do not provision bastion host within the edge VPC
 - Hostname of *example*
 - Domain of *test.com*
 - Console log in set to *Hello12345World*
 - Floating IP enabled for the external interface

   ```
   add_edge_vpc                        = true
   create_f5_network_on_management_vpc = false
   provision_teleport_on_f5            = false
   vpn_firewall_type                   = "waf"
   hostname                            = "example"
   domain                              = "test.com"
   tmos_admin_password                 = "Hello12345World" <!-- pragma: allowlist secret -->
   enable_f5_external_fip              = true
   enable_f5_management_fip            = false
   ```


More information in regards to the meaning of each variable can be found within the documenation for the pattern:

   - [VSI](../../patterns/vsi#module-variables)
   - [Mixed](../../patterns/mixed#module-variables)
   - [ROKS](../../patterns/roks#module-variables)

### Accessing the F5 BIG-IP

After you provision the F5 BIG-IP using SLZ, you are able to access the management console by using the Floating IP address (if enabled) that is provisioned on the virtual server instance either on the management or external interface.  Use the `tmos_admin_password` that you set above to access it.

### Toolchain provisioning

If you use the IBM Cloud DevOps toolchain for Secure Landing Zone, Code Risk Analyzer will fail due to allowing in_addr_any traffic and IP-spoofing being enabled.  To skip the failure, you can set the **cra-skip-failure** to `true`.  More information on the toolchain variables can be found [here](../toolchain/toolchain.md).

```
Failed SCC goals:
	 Goal ID 3000410: Ensure Virtual Private Cloud (VPC) security groups have no inbound ports open to the internet (0.0.0.0/0)
		Found in:
			resource_address: module.landing-zone.ibm_is_security_group_rule.security_group_rules["f5-external-sg-allow-inbound-443"]
	 Goal ID 3000455: Ensure Virtual Servers for VPC instance has all interfaces with IP-spoofing disabled
		Found in:
			resource_address: module.landing-zone.module.f5_vsi["arg-f5-zone-2"].ibm_is_instance.vsi["test-f5-zone-2-1"]
			resource_address: module.landing-zone.module.f5_vsi["arg-f5-zone-3"].ibm_is_instance.vsi["test-f5-zone-3-1"]
			resource_address: module.landing-zone.module.f5_vsi["arg-f5-zone-1"].ibm_is_instance.vsi["test-f5-zone-1-1"]
```

### Setup of client-to-site VPN and WAF

For instructions on the setup of client-to-site VPN and WAF, please visit this [link](https://cloud.ibm.com/docs/allowlist/framework-financial-services?topic=framework-financial-services-vpc-architecture-connectivity-f5-tutorial).

### ACL and Security Groups

By default, Secure Landing Zone provisions ACL's and Security Groups that are more open and non-customer dependent.  Please utilize [override.json](../../README.md#using-overridejson) file to manipulate add/delete rules appropriately for your environment.
