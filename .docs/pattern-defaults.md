# Default Secure Landing Zone Configuration

## Pattern Variables

Each Landing Zone pattern takes in a small number of variables, enabling you to quickly and easily get started with IBM Cloud. Each pattern requires only the `ibmcloud_api_key`, `prefix`, and `region` variables to get started (the `ssh_public_key` must also be provided by the user when creating a pattern that uses Virtual Servers).

---

### Variables Available in Each Pattern

Name                                | Type         | Description                                                                                                                                                                                                                                                                                                                                                     | Sensitive | Default
----------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | --------------------------------------------------------
ibmcloud_api_key                    | string       | The IBM Cloud platform API key needed to deploy IAM enabled resources.                                                                                                                                                                                                                                                                                          | true      |
TF_VERSION                          | string       | The version of the Terraform engine that's used in the Schematics workspace.                                                                                                                                                                                                                                                                                    |           | 1.0
prefix                              | string       | A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters.                                                                                                                         |           |
region                              | string       | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions.                                                                                                                                                                                                                                         |           |
tags                                | list(string) | List of tags to apply to resources created by this module.                                                                                                                                                                                                                                                                                                      |           | []
network_cidr                        | string       | Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning.                                                                                                                                                                                                                                                                    |           | 10.0.0.0/8
vpcs                                | list(string) | List of VPCs to create. The first VPC in this list will always be considered the `management` VPC, and will be where the VPN Gateway is connected. VPCs names can only be a maximum of 16 characters and can only contain lowercase letters, numbers, and - characters. VPC names must begin with a lowercase letter and end with a lowercase letter or number. |           | ["management", "workload"]
enable_transit_gateway              | bool         | Create transit gateway                                                                                                                                                                                                                                                                                                                                          |           | true
add_atracker_route                  | bool         | Atracker can only have one route per zone. Use this value to disable or enable the creation of atracker route                                                                                                                                                                                                                                                   |           | true
hs_crypto_instance_name             | string       | Optionally, you can bring you own Hyper Protect Crypto Service instance for key management. If you would like to use that instance, add the name here. Otherwise, leave as null                                                                                                                                                                                 |           | null
hs_crypto_resource_group            | string       | If you're using Hyper Protect Crypto services in a resource group other than `Default`, provide the name here.                                                                                                                                                                                                                                                  |           | null
override                            | bool         | Override default values with custom JSON template. This uses the file `override.json` to allow users to create a fully customized environment.                                                                                                                                                                                                                  |           | false

---

### Variables for Patterns Including Virtual Servers

For the [mixed pattern](../patterns/mixed/) and [vsi pattern](../patterns/vsi):


Name                                | Type         | Description                                                                                                                                                                                                                                                                                                                                                     | Sensitive | Default
----------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | --------------------------------------------------------
ssh_public_key                      | string       | Public SSH Key for VSI creation. Must be a valid SSH key that does not already exist in the deployment region.                                                                                                                                                                                                                                                  |           |
vsi_image_name                      | string       | VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images.                                                                                                                                                                                                                                                                    |           | ibm-ubuntu-18-04-6-minimal-amd64-2
vsi_instance_profile                | string       | VSI image profile. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles.                                                                                                                                                                                                                                               |           | cx2-4x8
vsi_per_subnet                      | number       | Number of Virtual Servers to create on each VSI subnet.                                                                                                                                                                                                                                                                                                         |           | 1

---

### Variables for Patterns Including OpenShift Clusters

For the [mixed pattern](../patterns/mixed/) and the [roks pattern](../patterns/roks/) these variables are available to the user.

Name                                | Type         | Description                                                                                                                                                                                                                                                                                                                                                     | Sensitive | Default
----------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | --------------------------------------------------------
cluster_zones                       | number       | Number of zones to provision clusters for each VPC. At least one zone is required. Can be 1, 2, or 3 zones.                                                                                                                                                                                                                                                                                                                                                                         |           | 3
kube_version                        | string       | Kubernetes version to use for cluster. To get available versions, use the IBM Cloud CLI command `ibmcloud ks versions`. To use the default version, leave as default. Updates to the default versions may force this to change.                                                                                                                                                                                                                                                     |           | default
flavor                              | string       | Machine type for cluster. Use the IBM Cloud CLI command `ibmcloud ks flavors` to find valid machine types                                                                                                                                                                                                                                                                                                                                                                           |           | bx2.16x64
workers_per_zone                    | number       | Number of workers in each zone of the cluster. OpenShift requires at least 2 workers.                                                                                                                                                                                                                                                                                                                                                                                               |           | 1
wait_till                           | string       | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady` |           | IngressReady
update_all_workers                  | bool         | Update all workers to new kube version                                                                                                                                                                                                                                                                                                                                                                                                                                              |           | false
entitlement                         | string       | If you do not have an entitlement, leave as null. Entitlement reduces additional OCP Licence cost in OpenShift clusters. Use Cloud Pak with OCP Licence entitlement to create the OpenShift cluster. Note It is set only when the first time creation of the cluster, further modifications are not impacted Set this argument to cloud_pak only if you use the cluster with a Cloud Pak that has an OpenShift entitlement.                                                         |           | null

---

## Resource Groups

Each of these resource groups will have the `prefix` variable and a hyphen prepended to the name (ex. `slz-management-rg` if the prefix is `slz`).

Name            | Description
----------------|------------------------------------------------
`management-rg` | Management Virtual Infrastructure Components
`workload-rg`   | Workload Virtual Infrastructure Components
`service-rg`    | Cloud Service Instances

---

## Cloud Services

![services](./images/resources.png)

### Key Management

By default a Key Protect instance is created unless the `hs_crypto_instance_name` variable is provided. Key Protect instances by default will be provisioned in the `service-rg` resource group.

---

#### Keys

Name            | Description
----------------|------------------------------------------------
`atracker-key`  | Encryption key for Activity Tracker Instance
`slz-key`       | Landing Zone services encryption key

---

### Cloud Object Storage

Two Cloud Object Storage instances are created in the `service-rg` by default

Name            | Description
----------------|------------------------------------------------
`atracker-cos`  | Object storage for Activity Tracker
`cos`           | Object storage

---

#### Object Storage Buckets

Name                | Instance       | Encryption Key | Description
--------------------|----------------|----------------|---------------------------------------------
`atracker-bucket`   | `atracker-cos` | `atracker-key` | Bucket for activity tracker logs
`management-bucket` | `cos`          | `slz-key`      | Bucket for flow logs from Management VPC
`workload-bucket`   | `cos`          | `slz-key`      | Bucket for flow logs from Workload VPC

---

#### Object Storage API Keys

An API key is automatially generated for the `atracker-cos` instance to allow Activity Tracker to connect successfully to Cloud Object Storage

---

### Activity Tracker

An [Activity Tracker](url-here) instance is provisioned for this architecture.

---

## VPC Infrastructure

![network](./images/network.png)

By default, two VPCs ae created `management` and `workload`. All the components for the management VPC are provisioned in the `management-rg` resource group and the workload VPC components are all provisioned in the `workload-rg` resource group.

---

### Network Access Control Lists

An [Access Control List](https://cloud.ibm.com/docs/vpc?topic=vpc-using-acls) is created for each VPC to allow inbound communiction within the network, inbound communication from IBM services, and to allow all outbound traffic.

Rule                        | Action | Direction | Source        | Destination
----------------------------|--------|-----------|---------------|----------------
`allow-ibm-inbound`         | Allow  | Inbound   | 161.26.0.0/16 | 10.0.0.0/8
`allow-all-network-inbound` | Allow  | Inbound   | 10.0.0.0/8    | 10.0.0.0/8
`allow-all-outbound`        | Allow  | Outbound  | 0.0.0.0/0     | 0.0.0.0/0

#### Cluster Rules

In order to make sure that clusters can be created on VPCs, by default the following rules are added to ACLs where clusters are provisioned. For more information about controlling OpenShift cluster traffic with ACLs, see the documentation [here](https://cloud.ibm.com/docs/openshift?topic=openshift-vpc-acls).

Rule                                               | Action | TCP / UDP | Direction | Source        | Source Port   | Destination   | Destination Port
---------------------------------------------------|--------|-----------|-----------|---------------|---------------|---------------|-------------------
Create Worker Nodes                                | Allow  | Any       | inbound   | 161.26.0.0/16 | any           | 10.0.0.0/8    | any
Communicate with Service Instances                 | Allow  | Any       | inbound   | 166.8.0.0/14  | any           | 10.0.0.0/8    | any
Allow Incling Application Traffic                  | Allow  | TCP       | inbound   | 10.0.0.0/8    | 30000 - 32767 | 10.0.0.0/8    | any
Expose Applications Using Load Balancer or Ingress | Allow  | TCP       | inbound   | 10.0.0.0/8    | any           | 10.0.0.0/8    | 443
Create Worker Nodes                                | Allow  | Any       | outbound  | 10.0.0.0/8    | any           | 161.26.0.0/16 | any
Communicate with Service Instances                 | Allow  | Any       | outbound  | 10.0.0.0/8    | any           | 166.8.0.0/14  | any
Allow Incling Application Traffic                  | Allow  | TCP       | outbound  | 10.0.0.0/8    | any           | 10.0.0.0/8    | 30000 - 32767
Expose Applications Using Load Balancer or Ingress | Allow  | TCP       | outbound  | 10.0.0.0/8    | 443           | 10.0.0.0/8    | any

---

### Subnets

Each VPC creates two tiers of subnets, each attached to the Network ACL created for that VPC. The Management VPC also has a subnet created for creation of the VPN Gateway

#### Management VPC Subnets

Subnet Tier | Zone 1 Subnet Name | Zone 1 CIDR   | Zone 2 Subnet Name | Zone 2 CIDR   | Zone 3 Subnet Name | Zone 3 CIDR   |
------------|--------------------|---------------|--------------------|---------------|--------------------|---------------|
`vsi`       | `vsi-zone-1`       | 10.10.10.0/24 | `vsi-zone-2`       | 10.10.20.0/24 | `vsi-zone-3`       | 10.10.30.0/24 |
`vpe`       | `vpe-zone-1`       | 10.20.10.0/24 | `vpe-zone-2`       | 10.20.20.0/24 | `vsi-zone-3`       | 10.20.30.0/24 |
`vpn`       | `vpn-zone-1`       | 10.30.10.0/24 |


#### Workload VPC Subnets

Subnet Tier | Zone 1 Subnet Name | Zone 1 CIDR   | Zone 2 Subnet Name | Zone 2 CIDR   | Zone 3 Subnet Name | Zone 3 CIDR   |
------------|--------------------|---------------|--------------------|---------------|--------------------|---------------|
`vsi`       | `vsi-zone-1`       | 10.40.10.0/24 | `vsi-zone-2`       | 10.40.20.0/24 | `vsi-zone-3`       | 10.40.30.0/24 |
`vpe`       | `vpe-zone-1`       | 10.50.10.0/24 | `vpe-zone-2`       | 10.50.20.0/24 | `vsi-zone-3`       | 10.50.30.0/24 |

---

### Flow Logs

Using the COS bucket provisioned for each VPC network, a flow log collector is created.

![flow logs](./images/flowlogs.png)

----

### Virtual Private Endpoints

Each VPC dyamically has a Virtual Private Endpoint addess for the `cos` instance created in each zone of that VPC's `vpe` subnet tier.

![vpe](./images/vpe.png)

---

### Default VPC Security Group

The default VPC security group allows all outbound traffic and inbound traffic from within the security group.

---

## Virtual Sever Deployments

For the `vsi` pattern, identical virtual server deployments are created on each zone of the `vsi` tier of each VPC. For the `mixed` pattern, virtual servers are created only on the Management VPC. The number of these Virtual servers can be changed using the `vsi_per_subnet` variable.

### Boot Volume Encryption

Boot volumes for each virtual server are encrypted by the `slz-key`

### Virtual Server Image

To find available virtual servers in your region, use the IBM Cloud CLI Command:

```shell
ibmcloud is images
```

### Virtual Server Profile

To find available hardware configurations in your region, use the IBM Cloud CLI Command:

```shell
ibmcloud is instance-profiles
```

### Additional Components

Virtual Server components like additional block storage and Load Balancers can be configured using `override.json` and those variable definitions can be found in the [landing-zone module](../landing-zone/variables.tf#L457)

---

## OpenShift Cluster Deployments

For the `roks` pattern, identical Red Hat OpenShift Cluster deployments are created on each zone of the `vsi` tier of each VPC. For the `mixed` pattern, Clusters are created only on the Workload VPC. Cluster can be deployed across 1, 2, or 3 zones using the `cluster_zones` variable.

Clusters deployed use the most recent default cluster version.

---

### Workers Per Zone

The number of workers in each zone of the cluster can be changed by using the `workers_per_subnet` variable. At least two workers must be available for clusters to successfully provision.

---

### Cluster Flavor

To find available hardware configurations in your region, use the IBM Cloud CLI Command:

```shell
ibmcloud ks flavors
```
