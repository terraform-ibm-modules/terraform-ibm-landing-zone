# Secure Landing Zone

This module creates a secure landing zone within a single region.

---

## Table of Contents

1. [VPC](#vpc)
    - [VPCs Variable](#vpcs-variable)
    - [Flow Logs](#flow-logs)
3. [Transit Gateway](#transit-gateway)
4. [Security Groups](#security-groups)
    - [Security Groups Variable](#security-groups-variable)
5. [Virtual Servers](#virtual-servers)
    - [VPC SSH Keys](#vpc-ssh-keys)
    - [SSH Keys Variable](#ssh-keys-variable)
    - [Virtual Servers Variable](#virtual-servers-variable)
6. [Cluster and Worker pool](#cluster-and-worker-pool)
7. [IBM Cloud Services](#ibm-cloud-services)
8. [Virtual Private Endpoints](#virtual-private-endpoints)
9. [IBM Cloud Services](#ibm-cloud-services-1)
    - [Cloud Object Storage](#cloud-object-storage)
10. [VPC Placement Groups](#vpc-placement-groups)
11. [Security and Compliance Center](#security-and-compliance-center)
12. [Module Variables](#module-variables)
13. [Contributing](#contributing)
14. [Terraform Language Resources](#terraform-language-resources)
15. [Using This Architecure as a Template for Multiple Patterns](#as-a-template-for-multiple-patterns)
16. [Creating An Issue](#creating-an-issue)

---

## VPC

![vpc-module](../.docs/vpc-module.png)

This template allows users to create any number of VPCs in a single region. The VPC network and components are created by the [Cloud Schematics VPC module](https://github.com/Cloud-Schematics/multizone-vpc-module). VPC components can be found in [main.tf](./main.tf)

### VPCs Variable

The list of VPCs from the `vpcs` variable is transformed into a map, allowing for additions and deletion of resources without forcing updates. The VPC Network includes:

- VPC
- Subnets
- Network ACLs
- Public Gateways
- VPN Gateway and Gateway Connections

The type of the VPC Variable is as follows:

```terraform
  type = list(
    object({
      prefix                      = string            # A unique prefix that will prepend all components in the VPC
      resource_group              = optional(string)  # Name of the resource group to use for VPC. Must by in `var.resource_groups`
      use_manual_address_prefixes = optional(bool)    # Optionally assign prefixes to VPC manually. By default this is false, and prefixes will be created along with subnets
      classic_access              = optional(bool)    # Optionally allow VPC to access classic infrastructure network
      default_network_acl_name    = optional(string)  # Override default ACL name
      default_security_group_name = optional(string)  # Override default VPC security group name
      default_routing_table_name  = optional(string)  # Override default VPC routing table name
      flow_logs_bucket_name       = optional(string)  # Name of COS bucket to use with flowlogs. Must be created by this template

      ##############################################################################
      # Use `address_prefixes` only if `use_manual_address_prefixes` is true
      # otherwise prefixes will not be created. Use only if you need to manage
      # prefixes manually.
      ##############################################################################

      address_prefixes = optional(
        object({
          zone-1 = optional(list(string))
          zone-2 = optional(list(string))
          zone-3 = optional(list(string))
        })
      )

      ##############################################################################

      ##############################################################################
      # List of network ACLs to create with VPC
      ##############################################################################

      network_acls = list(
        object({
          name                = string         # Name of ACL, this can be referenced by subnets to be connected on creation
          add_cluster_rules   = optional(bool) # Automatically add to ACL rules needed to allow cluster provisioning from private service endpoints

          ##############################################################################
          # List of rules to add to the ACL, by default all inbound and outbound traffic
          # will be allowed. By default, ACLs have a limit of 50 rules.
          ##############################################################################

          rules = list(
            object({
              name        = string # Name of ACL rule
              action      = string # Allow or deny traffic
              direction   = string # Inbound or outbound
              destination = string # Destination CIDR block
              source      = string # Source CIDR block

              ##############################################################################
              # Optionally the rule can be created for TCP, UDP, or ICMP traffic.
              # Only ONE of the following blocks can be used in a single ACL rule
              ##############################################################################

              tcp = optional(
                object({
                  port_max        = optional(number)
                  port_min        = optional(number)
                  source_port_max = optional(number)
                  source_port_min = optional(number)
                })
              )
              udp = optional(
                object({
                  port_max        = optional(number)
                  port_min        = optional(number)
                  source_port_max = optional(number)
                  source_port_min = optional(number)
                })
              )
              icmp = optional(
                object({
                  type = optional(number)
                  code = optional(number)
                })
              )
            })
            ##############################################################################
          )
        })
      )

      ##############################################################################


      ##############################################################################
      # Public Gateways
      # For each `zone` that is set to `true`, a public gateway will be created in
      # That zone
      ##############################################################################

      use_public_gateways = object({
        zone-1 = optional(bool)
        zone-2 = optional(bool)
        zone-3 = optional(bool)
      })

      ##############################################################################


      ##############################################################################
      # Object for subnets to be created in each zone, each zone can have any number
      # of subnets
      #
      # Each subnet accepts the four following arguments:
      # * name           - Name of the subnet
      # * cidr           - CIDR block for the subnet
      # * public_gateway - Optionally add a public gateway. This works only if the zone
      #                    for `use_public_gateway` is set to `true`
      # * acl_name       - Name of ACL to be attached. Name must be found in
      #                    `network_acl` object
      ##############################################################################

      subnets = object({
        zone-1 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
        }))
        zone-2 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
        }))
        zone-3 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
        }))
      })

      ##############################################################################

    })
  )
  ##############################################################################
```

---

## Flow Logs

Flow log collectors can be added to a VPC by adding the `flow_logs_bucket_name` parameter to the `vpc` object. Any bucket must be declared in the `cos` variable that manages Cloud Object Storage. Click [here](#cloud-object-storage) to read more about provisioning Cloud Object Storage with this template

---

## Transit Gateway

A transit gateway connecting any number of VPC to the same network can optionally be created by setting the `enable_transit_gateway` variable to `true`. A connection will be dynamically created for each vpc specified in the `transit_gateway_connections` variable.

Transit Gateway resource can be found in `transit_gateway.tf`.

---

## Security Groups

This module can provision any number of security groups within any of the provisioned VPC.

Security Group components can be found in [security_groups.tf](./security_groups.tf).

### Security Groups Variable

The `security_group` variable allows for the dynamic creation of security groups. This list is converted into a map before provision to ensure that changes, updates, and deletions won't impact other existing resources.

The `security_group` variable type is as follows:

```terraform
  list(
    object({
      name     = string # Name for each security group
      vpc_name = string # The group will be created. Only VPCs from `var.vpc` can be used

      ##############################################################################
      # List of rules to be added to the security group
      ##############################################################################

      rules = list(
        object({
          name      = string # Name of the rule
          direction = string # Inbound or outbound
          source    = string # Source CIDR to allow

          ##############################################################################
          # Optionally, security groups can allow ONE of the following blocks
          # additional rules will have to be created for different types of traffic
          ##############################################################################

          tcp = optional(
            object({
              port_max = number
              port_min = number
            })
          )
          udp = optional(
            object({
              port_max = number
              port_min = number
            })
          )
          icmp = optional(
            object({
              type = number
              code = number
            })
          )
        })

        ##############################################################################

      )

      ##############################################################################
    })
  )
```

---

## Virtual Servers

![Virtual Servers](../.docs/vsi-lb.png)

This module uses the [Cloud Schematics VSI Module](https://github.com/Cloud-Schematics/vsi-module) to let users create any number of VSI workloads. The VSI Module covers the following resources:

- Virtual Server Instances
- Block Storage for those Instances
- VPC Load Balancers for those instances

Virtual server components can be found in [virual_servers.tf](./virtual_servers.tf)

### VPC SSH Keys

This Template allows users to create or get from data any number of VPC SSH Keys using the `ssh_keys` variable.

### SSH Keys Variable

Users can add a name and optionally a public key. If `public_key` is not provided, the SSH Key will be retrieved using a `data` block

```terraform
  type = list(
    object({
      name           = string
      public_key     = optional(string)
      resource_group = optional(string) # Must be in var.resource_groups
    })
  )
```

### Virtual Servers Variable

The virtual server variable type is as follows:

```terraform
list(
    object({
      name            = string                  # Name to be used for each VSI created
      vpc_name        = string                  # Name of VPC from `vpcs` variable
      subnet_names    = list(string)            # Names of subnets where VSI will be provisioned
      ssh_keys        = list(string)            # List of SSH Keys from `var.ssh_keys` to use when provisioning.
      image_name      = string                  # Name of the image for VSI, use `ibmcloud is images` to view
      machine_type    = string                  # Name of machine type. Use `ibmcloud is in-prs` to view
      vsi_per_subnet  = number                  # Number of identical VSI to be created on each subnet
      user_data       = optional(string)        # User data to initialize instance
      resource_group  = optional(string)        # Name of resource group where VSI will be provisioned, must be in `var.resource_groups`
      security_groups = optional(list(string))  # Optional Name of additional security groups from `var.security groups` to add to VSI

      ##############################################################################
      # When creating VSI, users can optionally create a new security group for
      # those instances. These fields function the same as in `var.security_groups`
      ##############################################################################

      security_group  = optional(
        object({
          name = string
          rules = list(
            object({
              name      = string
              direction = string
              source    = string
              tcp = optional(
                object({
                  port_max = number
                  port_min = number
                })
              )
              udp = optional(
                object({
                  port_max = number
                  port_min = number
                })
              )
              icmp = optional(
                object({
                  type = number
                  code = number
                })
              )
            })
          )
        })
      )

      ##############################################################################

      ##############################################################################
      # Optionally block storage volumes can be created. A volume from this list
      # will be created and attached to each VSI
      ##############################################################################

      block_storage_volumes = optional(list(
        object({
          name           = string           # Volume name
          profile        = string           # Profile
          capacity       = optional(number) # Capacity
          iops           = optional(number) # IOPs
          encryption_key = optional(string) # Optionally provide kms key
        })
      ))

      ##############################################################################

      ##############################################################################
      # Any number of VPC Load Balancers
      ##############################################################################

      load_balancers = list(
        object({
          name              = string # Name of the load balancer
          type              = string # Can be public or private
          listener_port     = number # Port for front end listener
          listener_protocol = string # Protocol for listener. Can be `tcp`, `http`, or `https`
          connection_limit  = number # Connection limit
          algorithm         = string # Back end Pool algorithm can only be `round_robin`, `weighted_round_robin`, or `least_connections`.
          protocol          = string # Back End Pool Protocol can only be `http`, `https`, or `tcp`
          health_delay      = number # Health delay for back end pool
          health_retries    = number # Health retries for back end pool
          health_timeout    = number # Health timeout for back end pool
          health_type       = string # Load Balancer Pool Health Check Type can only be `http`, `https`, or `tcp`.
          pool_member_port  = string # Listener port

          ##############################################################################
          # A security group can optionally be created and attached to each load
          # balancer
          ##############################################################################

          security_group = optional(
            object({
              name = string
              rules = list(
                object({
                  name      = string
                  direction = string
                  source    = string
                  tcp = optional(
                    object({
                      port_max = number
                      port_min = number
                    })
                  )
                  udp = optional(
                    object({
                      port_max = number
                      port_min = number
                    })
                  )
                  icmp = optional(
                    object({
                      type = number
                      code = number
                    })
                  )
                })
              )
            })
          )

          ##############################################################################
        })
      )

      ##############################################################################

    })
  )
```

---

## (Optional) Bastion Host

Users can optionally provision a bastion host that have teleport installed. App ID will be used to authenticate users to access teleport. Teleport session recordings will be stored in a COS bucket.

Bastion host components can be found in [bastion_host.tf](./bastion_host.tf)

### App ID Variable

To use the bastion host, users has 2 options: either create new App ID instance or use an existing one.
If `use_data` is set to true then an existing App ID instance. If it's set to false then an App ID instance will be created.

```
object(
  {
    name                = optional(string)         # Name of existing or to be created APP ID instance
    resource_group      = optional(string)         # The resource group of the existing or to be created APP ID instance
    use_data            = optional(bool)           # Bool specifying to use existing or to be created APP ID instance
    keys                = optional(list(string))   # List of App ID resource keys
    use_appid           = bool                     # Bool specifying to connect App ID to bastion host or not
  }
)

```

### Teleport Config Data Variable

Teleport config data. This is used to create a single template for all teleport instances to use. Creating a single template allows for values to remain sensitive.

```
object(
  {
    teleport_license   = optional(string) # The PEM license file
    https_cert         = optional(string) # The https certificate used by bastion host for teleport
    https_key          = optional(string) # The https private key used by bastion host for teleport
    domain             = optional(string) # The domain of the bastion host
    cos_bucket_name    = optional(string) # Name of the COS bucket to store the session recordings
    cos_key_name       = optional(string) # Name of the COS instance resource key. Must be HMAC credentials
    teleport_version   = optional(string) # Version of Teleport Enterprise to use
    message_of_the_day = optional(string) # Banner message the is exposed to the user at authentication time
    hostname           = optional(string) # The hostname of the bastion host
    app_id_key_name    = optional(string) # Name of APP ID key

    ##############################################################################
    # A list of maps that contain the user email and the role you want to 
    # associate with them
    ##############################################################################

    claims_to_roles = optional(
      list(
        object({
          email = string
          roles = list(string)
        })
      )
    )
  }
)
```

### Teleport VSI Variable

The teleport vsi variable type is as follows:

```
list(
    object(
      {
        name                            = string           # Name to be used for each teleport VSI created
        vpc_name                        = string           # Name of VPC from `vpcs` variable
        resource_group                  = optional(string) # Name of resource group where the teleport VSI will be provisioned, must be in `var.resource_groups`
        subnet_name                     = string           # Name of the subnet where the teleport VSI will be provisioned
        ssh_keys                        = list(string)     # List of SSH Keys from `var.ssh_keys` to use when provisioning.
        boot_volume_encryption_key_name = string           # Name of boot_volume_encryption_key        
        image_name                      = string           # Name of the image for the teleport VSI, use `ibmcloud is images` to view
        machine_type                    = string           # Name of machine type. Use `ibmcloud is in-prs` to view
        
        ##############################################################################
        # When creating VSI, users can optionally create a new security group for
        # those instances. These fields function the same as in `var.security_groups`
        ##############################################################################

        security_groups = optional(list(string))
        security_group = optional(
          object({
            name = string
            rules = list(
              object({
                name      = string
                direction = string
                source    = string
                tcp = optional(
                  object({
                    port_max = number
                    port_min = number
                  })
                )
                udp = optional(
                  object({
                    port_max = number
                    port_min = number
                  })
                )
                icmp = optional(
                  object({
                    type = number
                    code = number
                  })
                )
              })
            )
          })
        )
        ##############################################################################

      }
    )
  )
```
---

## Cluster and Worker pool

You can create as many `iks` or `openshift` clusters and worker pools on vpc. Cluster variable type is as follows:

For `ROKS` clusters, ensure public gateways are enabled to allow your cluster to correctly provision ingress ALBs.

```terraform
list(
    object({
      name               = string           # Name of Cluster
      vpc_name           = string           # Name of VPC
      subnet_names       = list(string)     # List of vpc subnets for cluster
      workers_per_subnet = number           # Worker nodes per subnet.
      machine_type       = string           # Worker node flavor
      kube_type          = string           # iks or openshift
      kube_version       = optional(string) # Can be a version from `ibmcloud ks versions` or `default`. `null` will use the
      update_all_workers = optional(bool)   # if true, force all workers to update
      entitlement        = optional(string) # entitlement option for openshift
      pod_subnet         = optional(string) # Portable subnet for pods
      service_subnet     = optional(string) # Portable subnet for services
      resource_group     = string           # Resource Group used for cluster
      cos_name           = optional(string) # Name of COS instance Required only for OpenShift clusters
      kms_config = optional(
        object({
          crk_name         = string         # Name of key
          private_endpoint = optional(bool) # Private endpoint
        })
      )
      worker_pools = optional(
        list(
          object({
            name               = string           # Worker pool name
            vpc_name           = string           # VPC name
            workers_per_subnet = number           # Worker nodes per subnet
            flavor             = string           # Worker node flavor
            subnet_names       = list(string)     # List of vpc subnets for worker pool
            entitlement        = optional(string) # entitlement option for openshift
          })
        )
      )
    })
  )
```

---

## IBM Cloud Services

---

## Virtual Private Endpoints

Virtual Private endpoints can be created for any number of services. Virtual private endpoint components can be found in [vpe.tf](vpe.tf).

---

## IBM Cloud Services

### Cloud Object Storage

This module can provision a Cloud Object Storage instance or retrieve an existing Cloud Object Storage instance, then create any number of buckets within the desired instance. 

Cloud Object Storage components can be found in cos.tf. 

---

## Security and Compliance Center

Credentials need to be created from the patterns using an IBM Cloud API key for scc.tf to create a scope.

Security and Compliance Center components account_settings, collector, and scope can be found in [scc.tf](./scc.tf) and credential can be found in [main.tf](./patterns/PATTERN/main.tf).

### Security and Compliance Center Variable

The `location_id` represents the geographic area where Posture Management requests are handled and processed. If `is_public` is set to true, then the collector connects to resources in your account over a public network. If set to false, the collector connects to resources by using a private IP that is accessible only through IBM Cloud private network. The `collector_passphrase` is only necessary if credential passphrase is enabled.

```
object(
  {
    enable_scc            = bool
    location_id           = optional(string)
    is_public             = optional(bool)
    collector_passphrase  = optional(string)
    collector_description = optional(string)
    credential_id         = optional(string)
    scope_name            = optional(string)
    scope_description     = optional(string)
  }
)
```
## VPC Placement Groups

Any number of VPC placement groups can be created. For more information about VPC Placement groups see the documentation [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-placement-groups-for-vpc&interface=ui)

VPC placement groups can be found in vpc_placement_group.tf

---

## Module Variables

| Name                        | Description                                                                                                                               |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| ibmcloud_api_key            | The IBM Cloud platform API key needed to deploy IAM enabled resources.                                                                    |
| prefix                      | A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. |
| region                      | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions.                   |
| resource_group              | Name of resource group where all infrastructure will be provisioned.                                                                      |
| tags                        | List of tags to apply to resources created by this module.                                                                                |
| vpcs                        | A map describing VPCs to be created in this repo.                                                                                         |
| flow_logs                   | List of variables for flow log to connect to each VSI instance. Set `use` to false to disable flow logs.                                  |
| enable_transit_gateway      | Create transit gateway                                                                                                                    |
| transit_gateway_connections | Transit gateway vpc connections. Will only be used if transit gateway is enabled.                                                         |
| ssh_keys                    | SSH Keys to use for VSI Provision. If `public_key` is not provided, the named key will be looked up from data.                            |
| vsi                         | A list describing VSI workloads to create                                                                                                 |
| teleport_vsi                | A list of teleport vsi deployments                                                                                                        |
| teleport_config_data        | Teleport config data. This is used to create a single template for all teleport instances to use. Creating a single template allows for values to remain sensitive |
| appid                       | The App ID instance to be used for the teleport vsi deployments                                                                           |
| security_groups             | Security groups for VPC                                                                                                                   |
| virtual_private_endpoints   | Object describing VPE to be created                                                                                                       |
| use_atracker                | Use atracker and route                                                                                                                    |
| atracker                    | atracker variables                                                                                                                        |
| resource_groups             | A list of existing resource groups to reference and new groups to create                                                                  |
| clusters                    | A list of clusters on vpc. Also can add list of worker_pools to the clusters                                                              |
| cos                         |"Object describing the cloud object storage instance, buckets, and keys. Set `use_data` to false to create instance
| cos_resource_keys           | List of objects describing resource keys to create for cos instance                                                                       |
| cos_authorization_policies  | List of authorization policies to be created for cos instance                                                                             |
| cos_buckets                 | List of standard buckets to be created in desired cloud object storage instance                                                           |
| vpc_placement_groups        | List of VPC placement groups to create |

---

## Contributing

Create feature branches to add additional components. To integrate code changes create a pull request and tag @Jennifer-Valle.

If additional variables or added or existing variables are changed, update the [Module Variables](##module-variables) table. To automate this process, use the nodejs package [tfmdcli](https://www.npmjs.com/package/tfmdcli)

To contribute, be sure to have the [GCAT TF Linter](https://github.ibm.com/GCAT/tf-linter) installed and then configure the corresponding pre-commit hook. 

```
$ ln pre-commit.sh .git/hooks/pre-commit 
```

---

## Terraform Language Resources

- [Terraform Functions](https://www.terraform.io/language/functions)
- [Using the \* Operator (splat operator)](https://www.terraform.io/language/expressions/splat)
- [Custom Variable Validation Rules](https://www.terraform.io/language/values/variables#custom-validation-rules)

---

## As A Template For Multiple Patterns

The modular nature of this template allwos it to be used to provisioned architectures for VSI, Clusters, or a combination of both VSI and clusters. For each of these, a provider block anda copy of [variables.tf](variables.tf). By referencing this template as a module, it allows uers to add `clusters` or `vsi` by adding the relevant variable block.

### VSI

```terraform
module "vsi_pattern" {
  source                         = "github.ibm.com/slz-v2-poc/vpc-and-vsi-pattern2.git"
  prefix                         = var.prefix
  region                         = var.region
  tags                           = var.tags
  resource_groups                = var.resource_groups
  vpcs                           = var.vpcs
  flow_logs                      = var.flow_logs
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_resource_group = var.transit_gateway_resource_group
  transit_gateway_connections    = var.transit_gateway_connections
  ssh_keys                       = var.ssh_keys
  vsi                            = var.vsi
  security_groups                = var.security_groups
  virtual_private_endpoints      = var.virtual_private_endpoints
  cos                            = var.cos
  service_endpoints              = var.service_endpoints
  key_protect                    = var.key_protect
  atracker                       = var.atracker
}
```

### Cluster and VSI

```terraform
module "cluster_vsi_pattern" {
  source                         = "github.ibm.com/slz-v2-poc/vpc-and-vsi-pattern2.git"
  prefix                         = var.prefix
  region                         = var.region
  tags                           = var.tags
  resource_groups                = var.resource_groups
  vpcs                           = var.vpcs
  flow_logs                      = var.flow_logs
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_resource_group = var.transit_gateway_resource_group
  transit_gateway_connections    = var.transit_gateway_connections
  ssh_keys                       = var.ssh_keys
  vsi                            = var.vsi
  security_groups                = var.security_groups
  virtual_private_endpoints      = var.virtual_private_endpoints
  cos                            = var.cos
  service_endpoints              = var.service_endpoints
  key_protect                    = var.key_protect
  atracker                       = var.atracker
  clusters                       = var.clusters
  wait_till                      = var.wait_till
}
```

### Cluster

```terraform
module "cluster_pattern" {
  source                         = "github.ibm.com/slz-v2-poc/vpc-and-vsi-pattern2.git"
  prefix                         = var.prefix
  region                         = var.region
  tags                           = var.tags
  resource_groups                = var.resource_groups
  vpcs                           = var.vpcs
  flow_logs                      = var.flow_logs
  enable_transit_gateway         = var.enable_transit_gateway
  transit_gateway_resource_group = var.transit_gateway_resource_group
  transit_gateway_connections    = var.transit_gateway_connections
  ssh_keys                       = var.ssh_keys
  security_groups                = var.security_groups
  virtual_private_endpoints      = var.virtual_private_endpoints
  cos                            = var.cos
  service_endpoints              = var.service_endpoints
  key_protect                    = var.key_protect
  atracker                       = var.atracker
  clusters                       = var.clusters
  wait_till                      = var.wait_till
}
```

--- 

## Creating an Issue

As we develop the SLZ template, issues are bound to come up. When an issue comes up the following are required. Issues that do not have complete information will be **closed immediately**.

### Enhancement Feature 

- A detailed title that is either the source of a bug, or a user story for the feature that needs to be added.
  - example `As a user, I want to be able to provision encryption keys using either HPCS or Key Protect`
- Any additional information about the use case is helpful, so please be sure to include it.

### Bug Fixes

- A detailed title that is either the source of a bug
  - example `When provisioning ROKS, network ALBs cannot be provisioned.`
- If you are creating an issue related to a bug, a list of non-sensitive variables in code block format being used to create the architecture must be added to the issue description. This will enable us to recreate the issue locally and diagnose any problems that occur
- Additionally, if there are any logging errors, please include those **as text or as part of a code block**.
