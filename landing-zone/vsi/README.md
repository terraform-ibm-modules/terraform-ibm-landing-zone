# VSI on VPC Module

This module allows users to create any number of VSI across multple subnets with any number of block storage volumes, connected by any number of load balancers.

![vsi-module](./.docs/vsi-lb.png)

## Table of Contents

1. [Prerequisites](##Prerequisites)s
2. [Virtual Servers](##Virtual-Servers)
3. [Block Storage](##Block-Storage)
4. [Floating IPs](##Floating-IPs)
5. [Load Balancers](##Load-Balancers)
6. [Module Variables](##module-vairables)
7. [Module Outputs](##module-outputs)
8. [As A Module in a Larger Architecture](##As-A-Module-in-a-Larger-Architecture)

---

## Prerequisites

An existing VPC and VPC SSH Key

---

## Virtual Servers

This module creates Virtual servers across any number of subnets in a single VPC connected by a single security group. Users can specify how many virtual servers to provision on each subnet by using the `vsi_per_subnet` variable. Virtual servers use the prefix to dynamically create names. These names are also used as the terraform address for each Virtual Server, allowing for easy reference:

```terraform
module.vsi["test-vsi"].ibm_is_instance.vsi["test-vsi-1"]
module.vsi["test-vsi"].ibm_is_instance.vsi["test-vsi-2"]
module.vsi["test-vsi"].ibm_is_instance.vsi["test-vsi-3"]
```
---

## Block Storage Volumes

This module allows users to create any number of identical block storage volumes. One of each storage volume specified in the `volumes` variable will be created and attached to each virtual server. These block storage volumes use the Virtual Server name and the volume name to create easily identifiable and manageble addressess within terraform:

```terraform
module.vsi["test-vsi"].ibm_is_volume.volume["test-vsi-1-one"]
module.vsi["test-vsi"].ibm_is_volume.volume["test-vsi-2-one"]
module.vsi["test-vsi"].ibm_is_volume.volume["test-vsi-3-one"]
module.vsi["test-vsi"].ibm_is_volume.volume["test-vsi-1-two"]
module.vsi["test-vsi"].ibm_is_volume.volume["test-vsi-2-two"]
module.vsi["test-vsi"].ibm_is_volume.volume["test-vsi-3-two"]
```

---

## Floating IPs

By using the `enable_floating_ip` a floating IP will be assigned to each VSI created by this module. This floating IP will be displayed in the output if provisioned.

---

## Load Balancers

This module allows users to create any number of application Load Balancers to balance traffic between all Virtual Servers created by this module. Each Load Balancer can optionally be added to it's own security group. The `load_balancers` variable allows users to configure the back end pool and front end listener for each load balancer.

---

## Module Variables

Name                             | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Description
-------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------
resource_group_id                | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | id of resource group to create VPC
prefix                           | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | The IBM Cloud platform API key needed to deploy IAM enabled resources
tags                             | list(string)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | List of tags to apply to resources created by this module.
vpc_id                           | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | ID of VPC
subnets                          | list( object({ name = string id = string zone = string cidr = string }) )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | A list of subnet IDs where VSI will be deployed
image_id                         | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Image ID used for VSI. Run 'ibmcloud is images' to find available images in a region
ssh_key_ids                      | list(string)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | ssh key ids to use in creating vsi
machine_type                     | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles
vsi_per_subnet                   | number                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | Number of VSI instances for each subnet
user_data                        | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | User data to initialize VSI deployment
boot_volume_encryption_key       | string                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | CRN of boot volume encryption key
enable_floating_ip               | bool                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Create a floating IP for each virtual server created
allow_ip_spoofing                | bool                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Allow IP spoofing on the primary network interface
create_security_group            | bool                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Create security group for VSI. If this is passed as false, the default will be used
security_group                   | object({ name = string rules = list( object({ name = string direction = string source = string tcp = optional( object({ port_max = number port_min = number }) ) udp = optional( object({ port_max = number port_min = number }) ) icmp = optional( object({ type = number code = number }) ) }) ) })                                                                                                                                                                                                                                                                                                                    | Security group created for VSI
security_group_ids               | list(string)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | IDs of additional security groups to be added to VSI deployment primary interface. A VSI interface can have a maximum of 5 security groups.
block_storage_volumes            | list( object({ name = string profile = string capacity = optional(number) iops = optional(number) encryption_key = optional(string) }) )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | List describing the block storage volumes that will be attached to each vsi
load_balancers                   | list( object({ name = string type = string listener_port = number listener_protocol = string connection_limit = number algorithm = string protocol = string health_delay = number health_retries = number health_timeout = number health_type = string pool_member_port = string security_group = optional( object({ name = string rules = list( object({ name = string direction = string source = string tcp = optional( object({ port_max = number port_min = number }) ) udp = optional( object({ port_max = number port_min = number }) ) icmp = optional( object({ type = number code = number }) ) }) ) }) ) }) ) | Load balancers to add to VSI
secondary_subnets                | list( object({ name = string id = string zone = string cidr = string }) )                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | List of secondary network interfaces to add to vsi secondary subnets must be in the same zone as VSI. This is only recommended for use with a deployment of 1 VSI.
secondary_use_vsi_security_group | bool                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Use the security group created by this module in the secondary interface
secondary_security_group_ids     | list(string)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | IDs of additional security groups to be added to VSI deployment secondary interfaces. A VSI interface can have a maximum of 5 security groups.
secondary_allow_ip_spoofing      | bool                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Allow IP spoofing on additional network interfaces

---

## Module Outputs

Name                 | Description
-------------------- | -----------------------------------------------------------
ids                | The IDs of the VSI
vsi_security_group | Security group for the VSI
list               | A list of VSI with name, id, zone, and primary ipv4 address
lb_hostnames       | Hostnames for the Load Balancer created
lb_security_groups | Load Balancer security groups

---

## As A Module in a Larger Architecture

## Usage
```terraform
module vsi {
  source                           = "github.com/Cloud-Schematics/vsi-module.git"
  resource_group_id                = var.resource_group_id
  prefix                           = var.prefix
  tags                             = var.tags
  vpc_id                           = var.vpc_id
  subnets                          = var.subnets
  image_id                         = var.image_id
  ssh_key_ids                      = var.ssh_key_ids
  machine_type                     = var.machine_type
  vsi_per_subnet                   = var.vsi_per_subnet
  user_data                        = var.user_data
  boot_volume_encryption_key       = var.boot_volume_encryption_key
  enable_floating_ip               = var.enable_floating_ip
  allow_ip_spoofing                = var.allow_ip_spoofing
  create_security_group            = var.create_security_group
  security_group                   = var.security_group
  security_group_ids               = var.security_group_ids
  block_storage_volumes            = var.block_storage_volumes
  load_balancers                   = var.load_balancers
  secondary_subnets                = var.secondary_subnets
  secondary_use_vsi_security_group = var.secondary_use_vsi_security_group
  secondary_security_group_ids     = var.secondary_security_group_ids
  secondary_allow_ip_spoofing      = var.secondary_allow_ip_spoofing
}
```