<!-- BEGIN MODULE HOOK -->

<!-- Update the title to match the module name and add a description -->

# IBM Secure Landing Zone module

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![build status](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-landing-zone?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/releases/latest)

<!-- Remove the content in this H2 heading after completing the steps -->

The landing zone module can be used to create a fully customizable VPC environment within a single region. The three following patterns are starting templates that can be used to get started quickly with Landing Zone. These patterns are located in the [patterns](/patterns/) directory.

Each of these patterns creates the following infrastructure:

- A resource group for cloud services and for each VPC.
- Cloud Object Storage instances for flow logs and Activity Tracker
- Encryption keys in either a Key Protect or Hyper Protect Crypto Services instance
- A management and workload VPC connected by a transit gateway
- A flow log collector for each VPC
- All necessary networking rules to allow communication
- Virtual Private Endpoint (VPE) for Cloud Object Storage in each VPC
- A VPN gateway in the management VPC

Each pattern creates the following infrastructure on the VPC:

- The virtual server (VSI) pattern deploys identical virtual servers across the VSI subnet tier in each VPC
- The Red Hat OpenShift Kubernetes (ROKS) pattern deploys identical clusters across the VSI subnet tier in each VPC
- The mixed pattern provisions both of these elements

For more information about the default configuration, see [Default Secure Landing Zone configuration](.docs/pattern-defaults.md).

| Virtual server pattern           | Red Hat OpenShift pattern        | Mixed pattern                      |
| -------------------------------- | -------------------------------- | ---------------------------------- |
| ![VSI](./.docs/images/vsi.png)   | ![ROKS](./.docs/images/roks.png) | ![Mixed](./.docs/images/mixed.png) |

## Before you begin

Complete the following steps before you deploy the Secure Landing Zone module.
### Set up an IBM Cloud Account

1.  Make sure that you have an IBM Cloud Pay-As-You-Go or Subscription account:

    - If you don't have an IBM Cloud account, [create one](https://cloud.ibm.com/docs/account?topic=account-account-getting-started).
    - If you have a Trial or Lite account, [upgrade your account](https://cloud.ibm.com/docs/account?topic=account-upgrading-account).

### Configure your IBM Cloud account for Secure Landing Zone

1.  Log in to [IBM Cloud](https://cloud.ibm.com) with the IBMid you used to set up the account. This IBMid user is the account owner and has full IAM access.
1.  [Complete the company profile](https://cloud.ibm.com/docs/account?topic=account-contact-info) and contact information for the account. This profile is required to stay in compliance with IBM Cloud Financial Service profile.
1.  [Enable the Financial Services Validated option](https://cloud.ibm.com/docs/account?topic=account-enabling-fs-validated) for your account.
1.  Enable virtual routing and forwarding (VRF) and service endpoints by creating a support case. Follow the instructions in  [enabling VRF and service endpoints](https://cloud.ibm.com/docs/account?topic=account-vrf-service-endpoint&interface=ui#vrf).

### Set up account access (Cloud IAM)

1.  Create an IBM Cloud [API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key). The user who owns this key must have the Administrator role.
1.  Require users in your account to use [multifactor authentication (MFA)](https://cloud.ibm.com/docs/account?topic=account-account-getting-started#account-gs-mfa).
1.  [Set up access groups](https://cloud.ibm.com/docs/account?topic=account-account-getting-started#account-gs-accessgroups).
    User access to IBM Cloud resources is controlled by using the access policies that are assigned to access groups. For IBM Cloud Financial Services validation, all IAM users must not be assigned direct access to any IBM Cloud resources.

    Select **All Identity and Access enabled services** when you assign access to the group.

### (Optional) Set up IBM Cloud Hyper Protect Crypto Services

For Key Management services, you can use IBM Cloud Hyper Protect Crypto Services. Create an instance before you create the Secure Landing Zone.

1.  Create the service instance:

    1.  (Optional) [Create a resource group](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui) for your instance.
    1.  On the Hyper Protect Crypto Services (https://cloud.ibm.com/catalog/services/hyper-protect-crypto-services) details page, select a plan.
    1.  Complete the required details that are required and click **Create**.

1.  Initialize Hyper Protect Crypto Services:

    To initialize the provisioned Hyper Protect Crypto Service instance, follow the steps in [Getting started with IBM Cloud Hyper Protect Crypto Services](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-get-started).

    For proof-of-technology environments, use the `auto-init` flag. For more information, see [Initializing service instances using recovery crypto units](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-initialize-hsm-recovery-crypto-unit).

## Customize your environment

You can customize your environment with Secure Landing Zone in two ways: by using Terraform input variables or by using the `override.json` file.

### Customizing by using Terraform input variables

In the first method, you set a couple of required input variables of your respective pattern, and then provision the environment.

You can find the list of input variables in the `variables.tf` file of the pattern directory:

- [VSI pattern input variables](./patterns/vsi/variables.tf)
- [ROKS pattern input variables](./patterns/roks/variables.tf)
- [Mixed pattern input variables](./patterns/mixed/variables.tf)

Terraform supports multiple ways to set input variables. For more information, see [Input Variables](https://www.terraform.io/language/values/variables#assigning-values-to-root-module-variables) in the Terraform language documentation.

For example, you can add more VPCs by adding the name of the new VPC to the `vpcs` variable in the `variables.tf` file in your patterns directory.

```
vpcs  = ["management", "workload", "<ADDITIONAL VPC>"]
```

You can get more specific after you use this method. Running the Terraform outputs a JSON-based file that you can use in `override.json`.

### Customizing by using the override.json file

The second route is to use the `override.json` to create a fully customized environment based on the starting template. By default, each pattern's `override.json` is set to contain the default environment configuration. You can use the `override.json` in the respective pattern directory by setting the template input `override` variable to `true`. Each value in `override.json` corresponds directly to a variable value from this root module, which each pattern uses to create your environment.

#### Supported variables

Through the `override.json`, you can pass any variable or supported optional variable attributes from this root module, which each pattern uses to provision infrastructure. For a complete list of supported variables and attributes, see the [variables.tf ](variables.tf) file.

#### Overriding variables

After every execution of `terraform apply`, a JSON-encoded definition is output. This definition of your environment is based on the defaults for the Landing Zone and any variables that are changed in the `override.json` file. You can then use the output in the `override.json` file.

You can redirect the contents between the output lines by running the following commands:

```sh
config = <<EOT
EOT
```

After you replace the contents of the `override.json` file with your configuration, you can edit the resources within. Make use that you set the template `override` variable to `true` as an input variable. For example, within the `variables.tf` file.

Locally run configurations do not require a Terraform `apply` command to generate the `override.json`. To view your current configuration, run the `terraform refresh` command.

#### Overriding only some variables

The `override.json` file does not need to contain all elements. For example,

```json
{
  "enable_transit_gateway": false
}
```

## (Optional) F5 BIG-IP

The F5 BIG-IP Virtual Edition supports setting up a client-to-site full tunnel VPN to connect to your management or edge VPC or a web application firewall (WAF). With this configuration, you can connect to your workload VPC over the public internet.

Through Secure Landing Zone, you can optionally provision the F5 BIG-IP so that you can set up the implemented solution of a client-to-site VPN or web application firewall (WAF). For more information, see [Provisioning a F5 BIG-IP host by using Secure Landing Zone](.docs/f5-big-ip/f5-big-ip.md).

## (Optional) Bastion host by using Teleport

With Teleport, you can configure a virtual server instance in a VPC as a bastion host. Some of Teleport features include single sign-on to access the SSH server, auditing, and recording of your interactive sessions. For more information about Teleport, see the [Teleport documentation](https://goteleport.com/docs/).

Secure Landing Zone can set up a bastion host that uses Teleport. For more information, see [Provisioning a bastion host by using Teleport with Secure Landing Zone](.docs/bastion/bastion.md).

## Module recommendations for more features

| Feature | Description | Module | Version |
| --- | --- | --- | --- |
| Logging and Monitoring | Configure logging or monitoring for an existing Red Hat OpenShift cluster | [slzone/terraform-logmon-module](https://github.com/slzone/terraform-logmon-module) | v1.0.0 |

## Details about the Secure Landing Zone module

### VPC

![vpc-module](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc/blob/main/.docs/vpc-module.png?raw=true)

This template supports creating any number of VPCs in a single region. The VPC network and components are created by the [Secure Landing Zone VPC module](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc). The VPC components are described in the [main.tf](./main.tf) file.

#### vpcs variable

The list of VPCs from the `vpcs` variable is converted to a map, which supports adding and deleting resources without the need for an update. The VPC network includes the following aspects:

- VPC
- Subnets
- Network ACLs
- Public gateways
- VPN gateway and gateway connections

The following example shows the `vpc` variable type.

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

### Flow logs

You can add flow log collectors to a VPC by adding the `flow_logs_bucket_name` parameter to the `vpc` object. You declare each bucket in the `cos` variable that manages Cloud Object Storage. For more information about provisioning Cloud Object Storage with this template, see the [Cloud Object Storage](#cloud-object-storage) section.

### Transit gateway

You can create a transit gateway that connects any number of VPCs in the same network by setting the `enable_transit_gateway` variable to `true`. A connection is created for each VPC that you specify in the `transit_gateway_connections` variable. You configure the transit gateway resource in the [transit_gateway.tf](/transit_gateway.tf) file.

### Security groups

You can provision multiple security groups within any of the provisioned VPCs. You configure security group components in the [security_groups.tf](./security_groups.tf) file.

#### security_group variable

The `security_group` variable supports creating security groups dynamically. The list of groups is converted to a map to ensure that changes, updates, and deletions don't affect other resources.

The following example shows the `security_group` variable type.

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

### Virtual servers

![Virtual servers](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi/blob/main/.docs/vsi-lb.png?raw=true)

This module uses the [Cloud Schematics VSI Module](https://github.com/Cloud-Schematics/vsi-module) to support multiple VSI workloads. The VSI submodule covers the following resources:

- Virtual server instances
- Block storage for those instances
- VPC load balancers for those instances

Virtual server components can be found in [virtual_servers.tf](./virtual_servers.tf)

#### VPC SSH keys

You can use this template to create or return multiple VPC SSH keys by using the `ssh_keys` variable. For more information about how to locate an SSH key or create one, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) in the IBM Cloud docs.

#### ssh_keys variable

Users can add a name and optionally a public key. If `public_key` is not provided, the SSH key is retrieved by using a `data` block

```terraform
  type = list(
    object({
      name           = string
      public_key     = optional(string)
      resource_group = optional(string) # Must be in var.resource_groups
    })
  )
```

#### vis variable

The following example shows the `vsi` virtual server variable type.

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

## (Optional) Bastion host

You can provision a bastion host that uses Teleport. App ID is used to authenticate users to Teleport. Teleport session recordings are stored in a Cloud Object Storage bucket. You configure the bastion host components in the [bastion_host.tf](./bastion_host.tf) file.

### App ID variable

To use the bastion host, either create an App ID instance or use an existing one. If the `use_data` variable is set to `true`, an existing App ID instance is used. Set the variable to `false` create an App ID instance.

```terraform
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

### Teleport config data variable

The `teleport_config` block creates a single template for all teleport instances. By using a single template, the values remain hidden.

```terraform
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

### Teleport VSI variable

The following example shows the `teleport_vsi` variable type.

```terraform
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

## Cluster and worker pool

You can create as many `iks` or `openshift` clusters and worker pools on VPC. For `ROKS` clusters, make sure to enable public gateways to allow your cluster to correctly provision ingress application load balancers.

The following example shows the `cluster` variable type.

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

## Virtual private endpoints

Virtual private endpoints can be created for any number of services. Virtual private endpoint components are defined in the [vpe.tf](vpe.tf) file.

## IBM Cloud services

You can configure the following IBM Cloud services from this module.

### Cloud Object Storage

This module can provision a Cloud Object Storage instance or retrieve an existing one, and then create any number of buckets within the instance.

You define Cloud Object Storage components in the [cos.tf](cos.tf) file.

## Security and Compliance Center

You create credentials from the patterns by using an IBM Cloud API key for the `scc.tf` file to create a scope. You define the components, account_settings, collector, and scope for IBM Cloud Security and Compliance Center in the [scc.tf](scc.tf) file. You configure credentials in a `main.tf` file in the [patterns](/patterns/) directory.

### Security and Compliance Center variable

The `location_id` variable represents the geographic area where Posture Management requests are handled and processed. When `is_public` is set to `true`, the collector connects to resources in your account over a public network. When set to `false`, the collector connects to resources by using a private IP address that is accessible only through IBM Cloud Private network. The `collector_passphrase` is necessary only if credential passphrase is enabled.

```terraform
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

## VPC placement groups

You can create multiple VPC placement groups in the [vpc_placement_groups.tf](/vpc_placement_groups.tf) file. For more information about VPC placement groups, see [About placement groups](https://cloud.ibm.com/docs/vpc?topic=vpc-about-placement-groups-for-vpc&interface=ui) in the IBM Cloud Docs.

## Usage

<!-- Add sample usage of the module itself in the following code block -->

### Template for multiple patterns

You can use the modular design of this module to provision architectures for VSI, clusters, or a combination of both. Include a provider block and a copy of the [variables.tf](variables.tf) file. By referencing this template as a module, you support users who want to add `clusters` or a `vsi` by adding the relevant variable block.

#### VSI example

```terraform
module "vsi_pattern" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                         = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone.git?ref=main"
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

#### Cluster and VSI example

```terraform
module "cluster_vsi_pattern" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                         = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone.git?ref=main"
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

#### Cluster example

```terraform
module "cluster_pattern" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                         = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone.git?ref=main"
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

## Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
You need the following permissions to run this module.

- Account Management
    - **Sample Account Service** service
        - `Editor` platform access
        - `Manager` service access
    - IAM Services
        - **Sample Cloud Service** service
            - `Administrator` platform access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->
<!-- END MODULE HOOK -->

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Basic example](examples/basic)
- [ VPC landing zone (No compute example)](examples/no-compute-example)
- [ One VPC with one VSI](examples/one-vpc-one-vsi)
- [ Override.json example](examples/override-example)
- [ VSI on VPC landing zone (Quick start example)](examples/quickstart)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.5 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.3 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion_host"></a> [bastion\_host](#module\_bastion\_host) | git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi.git | v2.0.0 |
| <a name="module_dynamic_values"></a> [dynamic\_values](#module\_dynamic\_values) | ./dynamic_values | n/a |
| <a name="module_f5_vsi"></a> [f5\_vsi](#module\_f5\_vsi) | git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi.git | v2.0.0 |
| <a name="module_key_management"></a> [key\_management](#module\_key\_management) | ./kms | n/a |
| <a name="module_placement_group_map"></a> [placement\_group\_map](#module\_placement\_group\_map) | ./dynamic_values/config_modules/list_to_map | n/a |
| <a name="module_ssh_keys"></a> [ssh\_keys](#module\_ssh\_keys) | ./ssh_key | n/a |
| <a name="module_teleport_config"></a> [teleport\_config](#module\_teleport\_config) | ./teleport_config | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git | v5.0.1 |
| <a name="module_vsi"></a> [vsi](#module\_vsi) | git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vsi.git | v2.0.0 |

## Resources

| Name | Type |
|------|------|
| [ibm_appid_redirect_urls.urls](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/appid_redirect_urls) | resource |
| [ibm_atracker_route.atracker_route](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/atracker_route) | resource |
| [ibm_atracker_target.atracker_target](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/atracker_target) | resource |
| [ibm_container_vpc_cluster.cluster](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/container_vpc_cluster) | resource |
| [ibm_container_vpc_worker_pool.pool](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/container_vpc_worker_pool) | resource |
| [ibm_cos_bucket.buckets](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_iam_access_group.groups](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group) | resource |
| [ibm_iam_access_group_dynamic_rule.dynamic_rules](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group_dynamic_rule) | resource |
| [ibm_iam_access_group_members.group_members](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group_members) | resource |
| [ibm_iam_access_group_policy.account_management_policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group_policy) | resource |
| [ibm_iam_access_group_policy.policies](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_access_group_policy) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_account_settings) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_is_flow_log.flow_logs](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_flow_log) | resource |
| [ibm_is_placement_group.placement_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_placement_group) | resource |
| [ibm_is_security_group.security_group](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group) | resource |
| [ibm_is_security_group_rule.security_group_rules](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_security_group_rule) | resource |
| [ibm_is_subnet_reserved_ip.ip](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_subnet_reserved_ip) | resource |
| [ibm_is_virtual_endpoint_gateway.endpoint_gateway](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_virtual_endpoint_gateway) | resource |
| [ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_virtual_endpoint_gateway_ip) | resource |
| [ibm_is_vpn_gateway.gateway](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway) | resource |
| [ibm_is_vpn_gateway_connection.gateway_connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_vpn_gateway_connection) | resource |
| [ibm_resource_group.resource_groups](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_group) | resource |
| [ibm_resource_instance.appid](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.cos](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_instance.secrets_manager](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.appid_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_key.key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_scc_account_settings.ibm_scc_account_settings_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_account_settings) | resource |
| [ibm_scc_posture_collector.collector](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_posture_collector) | resource |
| [ibm_scc_posture_scope.scc_scope](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/scc_posture_scope) | resource |
| [ibm_tg_connection.connection](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/tg_connection) | resource |
| [ibm_tg_gateway.transit_gateway](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/tg_gateway) | resource |
| [random_string.random_cos_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [ibm_container_cluster_versions.cluster_versions](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/container_cluster_versions) | data source |
| [ibm_is_image.image](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_image) | data source |
| [ibm_resource_group.resource_groups](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.appid](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |
| [ibm_resource_instance.cos](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_groups"></a> [access\_groups](#input\_access\_groups) | A list of access groups to create | <pre>list(<br>    object({<br>      name        = string # Name of the group<br>      description = string # Description of group<br>      policies = list(<br>        object({<br>          name  = string       # Name of the policy<br>          roles = list(string) # list of roles for the policy<br>          resources = object({<br>            resource_group       = optional(string) # Name of the resource group the policy will apply to<br>            resource_type        = optional(string) # Name of the resource type for the policy ex. "resource-group"<br>            resource             = optional(string) # The resource of the policy definition<br>            service              = optional(string) # Name of the service type for the policy ex. "cloud-object-storage"<br>            resource_instance_id = optional(string) # ID of a service instance to give permissions<br>          })<br>        })<br>      )<br>      dynamic_policies = optional(<br>        list(<br>          object({<br>            name              = string # Dynamic group name<br>            identity_provider = string # URI for identity provider<br>            expiration        = number # How many hours authenticated users can work before refresh<br>            conditions = object({<br>              claim    = string # key value to evaluate the condition against.<br>              operator = string # The operation to perform on the claim. Supported values are EQUALS, EQUALS_IGNORE_CASE, IN, NOT_EQUALS_IGNORE_CASE, NOT_EQUALS, and CONTAINS.<br>              value    = string # Value to be compared agains<br>            })<br>          })<br>        )<br>      )<br>      account_management_policies = optional(list(string))<br>      invite_users                = optional(list(string)) # Users to invite to the access group<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_add_kms_block_storage_s2s"></a> [add\_kms\_block\_storage\_s2s](#input\_add\_kms\_block\_storage\_s2s) | add kms to block storage s2s authorization | `bool` | `true` | no |
| <a name="input_appid"></a> [appid](#input\_appid) | The App ID instance to be used for the teleport vsi deployments | <pre>object({<br>    name           = optional(string)<br>    resource_group = optional(string)<br>    use_data       = optional(bool)<br>    keys           = optional(list(string))<br>    use_appid      = bool<br>  })</pre> | <pre>{<br>  "use_appid": false<br>}</pre> | no |
| <a name="input_atracker"></a> [atracker](#input\_atracker) | atracker variables | <pre>object({<br>    resource_group        = string<br>    receive_global_events = bool<br>    collector_bucket_name = string<br>    add_route             = bool<br>  })</pre> | n/a | yes |
| <a name="input_clusters"></a> [clusters](#input\_clusters) | A list describing clusters workloads to create | <pre>list(<br>    object({<br>      name               = string           # Name of Cluster<br>      vpc_name           = string           # Name of VPC<br>      subnet_names       = list(string)     # List of vpc subnets for cluster<br>      workers_per_subnet = number           # Worker nodes per subnet.<br>      machine_type       = string           # Worker node flavor<br>      kube_type          = string           # iks or openshift<br>      kube_version       = optional(string) # Can be a version from `ibmcloud ks versions` or `latest`<br>      entitlement        = optional(string) # entitlement option for openshift<br>      pod_subnet         = optional(string) # Portable subnet for pods<br>      service_subnet     = optional(string) # Portable subnet for services<br>      resource_group     = string           # Resource Group used for cluster<br>      cos_name           = optional(string) # Name of COS instance Required only for OpenShift clusters<br>      update_all_workers = optional(bool)   # If true force workers to update<br>      kms_config = optional(<br>        object({<br>          crk_name         = string         # Name of key<br>          private_endpoint = optional(bool) # Private endpoint<br>        })<br>      )<br>      worker_pools = optional(<br>        list(<br>          object({<br>            name               = string           # Worker pool name<br>            vpc_name           = string           # VPC name<br>            workers_per_subnet = number           # Worker nodes per subnet<br>            flavor             = string           # Worker node flavor<br>            subnet_names       = list(string)     # List of vpc subnets for worker pool<br>            entitlement        = optional(string) # entitlement option for openshift<br>          })<br>        )<br>      )<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_cos"></a> [cos](#input\_cos) | Object describing the cloud object storage instance, buckets, and keys. Set `use_data` to false to create instance | <pre>list(<br>    object({<br>      name           = string<br>      use_data       = optional(bool)<br>      resource_group = string<br>      plan           = optional(string)<br>      random_suffix  = optional(bool) # Use a random suffix for COS instance<br>      buckets = list(object({<br>        name                  = string<br>        storage_class         = string<br>        endpoint_type         = string<br>        force_delete          = bool<br>        single_site_location  = optional(string)<br>        region_location       = optional(string)<br>        cross_region_location = optional(string)<br>        kms_key               = optional(string)<br>        allowed_ip            = optional(list(string))<br>        hard_quota            = optional(number)<br>        archive_rule = optional(object({<br>          days    = number<br>          enable  = bool<br>          rule_id = optional(string)<br>          type    = string<br>        }))<br>        activity_tracking = optional(object({<br>          activity_tracker_crn = string<br>          read_data_events     = bool<br>          write_data_events    = bool<br>        }))<br>        metrics_monitoring = optional(object({<br>          metrics_monitoring_crn  = string<br>          request_metrics_enabled = optional(bool)<br>          usage_metrics_enabled   = optional(bool)<br>        }))<br>      }))<br>      keys = optional(<br>        list(object({<br>          name        = string<br>          role        = string<br>          enable_HMAC = bool<br>        }))<br>      )<br><br>    })<br>  )</pre> | n/a | yes |
| <a name="input_enable_transit_gateway"></a> [enable\_transit\_gateway](#input\_enable\_transit\_gateway) | Create transit gateway | `bool` | `true` | no |
| <a name="input_f5_template_data"></a> [f5\_template\_data](#input\_f5\_template\_data) | Data for all f5 templates | <pre>object({<br>    tmos_admin_password     = optional(string)<br>    license_type            = optional(string)<br>    byol_license_basekey    = optional(string)<br>    license_host            = optional(string)<br>    license_username        = optional(string)<br>    license_password        = optional(string)<br>    license_pool            = optional(string)<br>    license_sku_keyword_1   = optional(string)<br>    license_sku_keyword_2   = optional(string)<br>    license_unit_of_measure = optional(string)<br>    do_declaration_url      = optional(string)<br>    as3_declaration_url     = optional(string)<br>    ts_declaration_url      = optional(string)<br>    phone_home_url          = optional(string)<br>    template_source         = optional(string)<br>    template_version        = optional(string)<br>    app_id                  = optional(string)<br>    tgactive_url            = optional(string)<br>    tgstandby_url           = optional(string)<br>    tgrefresh_url           = optional(string)<br>  })</pre> | <pre>{<br>  "license_type": "none"<br>}</pre> | no |
| <a name="input_f5_vsi"></a> [f5\_vsi](#input\_f5\_vsi) | A list describing F5 VSI workloads to create | <pre>list(<br>    object({<br>      name                   = string<br>      vpc_name               = string<br>      primary_subnet_name    = string<br>      secondary_subnet_names = list(string)<br>      secondary_subnet_security_group_names = list(<br>        object({<br>          group_name     = string<br>          interface_name = string<br>        })<br>      )<br>      ssh_keys                        = list(string)<br>      f5_image_name                   = string<br>      machine_type                    = string<br>      resource_group                  = optional(string)<br>      enable_management_floating_ip   = optional(bool)<br>      enable_external_floating_ip     = optional(bool)<br>      security_groups                 = optional(list(string))<br>      boot_volume_encryption_key_name = optional(string)<br>      hostname                        = string<br>      domain                          = string<br>      security_group = optional(<br>        object({<br>          name = string<br>          rules = list(<br>            object({<br>              name      = string<br>              direction = string<br>              source    = string<br>              tcp = optional(<br>                object({<br>                  port_max = number<br>                  port_min = number<br>                })<br>              )<br>              udp = optional(<br>                object({<br>                  port_max = number<br>                  port_min = number<br>                })<br>              )<br>              icmp = optional(<br>                object({<br>                  type = number<br>                  code = number<br>                })<br>              )<br>            })<br>          )<br>        })<br>      )<br>      block_storage_volumes = optional(list(<br>        object({<br>          name           = string<br>          profile        = string<br>          capacity       = optional(number)<br>          iops           = optional(number)<br>          encryption_key = optional(string)<br>        })<br>      ))<br>      load_balancers = optional(list(<br>        object({<br>          name              = string<br>          type              = string<br>          listener_port     = number<br>          listener_protocol = string<br>          connection_limit  = number<br>          algorithm         = string<br>          protocol          = string<br>          health_delay      = number<br>          health_retries    = number<br>          health_timeout    = number<br>          health_type       = string<br>          pool_member_port  = string<br>          security_group = optional(<br>            object({<br>              name = string<br>              rules = list(<br>                object({<br>                  name      = string<br>                  direction = string<br>                  source    = string<br>                  tcp = optional(<br>                    object({<br>                      port_max = number<br>                      port_min = number<br>                    })<br>                  )<br>                  udp = optional(<br>                    object({<br>                      port_max = number<br>                      port_min = number<br>                    })<br>                  )<br>                  icmp = optional(<br>                    object({<br>                      type = number<br>                      code = number<br>                    })<br>                  )<br>                })<br>              )<br>            })<br>          )<br>        })<br>      ))<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_iam_account_settings"></a> [iam\_account\_settings](#input\_iam\_account\_settings) | IAM Account Settings. | <pre>object({<br>    enable                          = bool<br>    mfa                             = optional(number)<br>    allowed_ip_addresses            = optional(string)<br>    include_history                 = optional(bool)<br>    if_match                        = optional(string)<br>    max_sessions_per_identity       = optional(string)<br>    restrict_create_service_id      = optional(string)<br>    restrict_create_platform_apikey = optional(string)<br>    session_expiration_in_seconds   = optional(string)<br>    session_invalidation_in_seconds = optional(string)<br>  })</pre> | <pre>{<br>  "enable": false<br>}</pre> | no |
| <a name="input_key_management"></a> [key\_management](#input\_key\_management) | Key Protect instance variables | <pre>object({<br>    name           = string<br>    resource_group = string<br>    use_data       = optional(bool)<br>    use_hs_crypto  = optional(bool)<br>    keys = optional(<br>      list(<br>        object({<br>          name            = string<br>          root_key        = optional(bool)<br>          payload         = optional(string)<br>          key_ring        = optional(string) # Any key_ring added will be created<br>          force_delete    = optional(bool)<br>          endpoint        = optional(string) # can be public or private<br>          iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>          encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.<br>          policies = optional(<br>            object({<br>              rotation = optional(<br>                object({<br>                  interval_month = number<br>                })<br>              )<br>              dual_auth_delete = optional(<br>                object({<br>                  enabled = bool<br>                })<br>              )<br>            })<br>          )<br>        })<br>      )<br>    )<br>  })</pre> | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning. | `string` | `"10.0.0.0/8"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions. | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Object describing resource groups to create or reference | <pre>list(<br>    object({<br>      name       = string<br>      create     = optional(bool)<br>      use_prefix = optional(bool)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_secrets_manager"></a> [secrets\_manager](#input\_secrets\_manager) | Map describing an optional secrets manager deployment | <pre>object({<br>    use_secrets_manager = bool<br>    name                = optional(string)<br>    kms_key_name        = optional(string)<br>    resource_group      = optional(string)<br>  })</pre> | <pre>{<br>  "use_secrets_manager": false<br>}</pre> | no |
| <a name="input_security_compliance_center"></a> [security\_compliance\_center](#input\_security\_compliance\_center) | Security and Compliance Center Variables | <pre>object({<br>    enable_scc            = bool<br>    location_id           = optional(string)<br>    is_public             = optional(bool)<br>    collector_description = optional(string)<br>    credential_id         = optional(string)<br>    scope_name            = optional(string)<br>    scope_description     = optional(string)<br>  })</pre> | <pre>{<br>  "enable_scc": false<br>}</pre> | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Security groups for VPC | <pre>list(<br>    object({<br>      name           = string<br>      vpc_name       = string<br>      resource_group = optional(string)<br>      rules = list(<br>        object({<br>          name      = string<br>          direction = string<br>          source    = string<br>          tcp = optional(<br>            object({<br>              port_max = number<br>              port_min = number<br>            })<br>          )<br>          udp = optional(<br>            object({<br>              port_max = number<br>              port_min = number<br>            })<br>          )<br>          icmp = optional(<br>            object({<br>              type = number<br>              code = number<br>            })<br>          )<br>        })<br>      )<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Service endpoints. Can be `public`, `private`, or `public-and-private` | `string` | `"private"` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH keys to use to provision a VSI. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). If `public_key` is not provided, the named key will be looked up from data. If a resource group name is added, it must be included in `var.resource_groups`. See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys. | <pre>list(<br>    object({<br>      name           = string<br>      public_key     = optional(string)<br>      resource_group = optional(string)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tags to apply to resources created by this module. | `list(string)` | `[]` | no |
| <a name="input_teleport_config_data"></a> [teleport\_config\_data](#input\_teleport\_config\_data) | Teleport config data. This is used to create a single template for all teleport instances to use. Creating a single template allows for values to remain sensitive | <pre>object({<br>    teleport_license   = optional(string)<br>    https_cert         = optional(string)<br>    https_key          = optional(string)<br>    domain             = optional(string)<br>    cos_bucket_name    = optional(string)<br>    cos_key_name       = optional(string)<br>    teleport_version   = optional(string)<br>    message_of_the_day = optional(string)<br>    hostname           = optional(string)<br>    app_id_key_name    = optional(string)<br>    claims_to_roles = optional(<br>      list(<br>        object({<br>          email = string<br>          roles = list(string)<br>        })<br>      )<br>    )<br>  })</pre> | `null` | no |
| <a name="input_teleport_vsi"></a> [teleport\_vsi](#input\_teleport\_vsi) | A list of teleport vsi deployments | <pre>list(<br>    object(<br>      {<br>        name                            = string<br>        vpc_name                        = string<br>        resource_group                  = optional(string)<br>        subnet_name                     = string<br>        ssh_keys                        = list(string)<br>        boot_volume_encryption_key_name = string<br>        image_name                      = string<br>        machine_type                    = string<br>        security_groups                 = optional(list(string))<br>        security_group = optional(<br>          object({<br>            name = string<br>            rules = list(<br>              object({<br>                name      = string<br>                direction = string<br>                source    = string<br>                tcp = optional(<br>                  object({<br>                    port_max = number<br>                    port_min = number<br>                  })<br>                )<br>                udp = optional(<br>                  object({<br>                    port_max = number<br>                    port_min = number<br>                  })<br>                )<br>                icmp = optional(<br>                  object({<br>                    type = number<br>                    code = number<br>                  })<br>                )<br>              })<br>            )<br>          })<br>        )<br><br><br>      }<br>    )<br>  )</pre> | `[]` | no |
| <a name="input_transit_gateway_connections"></a> [transit\_gateway\_connections](#input\_transit\_gateway\_connections) | Transit gateway vpc connections. Will only be used if transit gateway is enabled. | `list(string)` | n/a | yes |
| <a name="input_transit_gateway_resource_group"></a> [transit\_gateway\_resource\_group](#input\_transit\_gateway\_resource\_group) | Name of resource group to use for transit gateway. Must be included in `var.resource_group` | `string` | n/a | yes |
| <a name="input_virtual_private_endpoints"></a> [virtual\_private\_endpoints](#input\_virtual\_private\_endpoints) | Object describing VPE to be created | <pre>list(<br>    object({<br>      service_name   = string<br>      service_type   = string<br>      resource_group = optional(string)<br>      vpcs = list(<br>        object({<br>          name                = string<br>          subnets             = list(string)<br>          security_group_name = optional(string)<br>        })<br>      )<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_vpc_placement_groups"></a> [vpc\_placement\_groups](#input\_vpc\_placement\_groups) | List of VPC placement groups to create | <pre>list(<br>    object({<br>      access_tags    = optional(list(string))<br>      name           = string<br>      resource_group = optional(string)<br>      strategy       = string<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | A map describing VPCs to be created in this repo. | <pre>list(<br>    object({<br>      prefix                      = string           # VPC prefix<br>      resource_group              = optional(string) # Name of the group where VPC will be created<br>      use_manual_address_prefixes = optional(bool)<br>      classic_access              = optional(bool)<br>      default_network_acl_name    = optional(string)<br>      default_security_group_name = optional(string)<br>      default_security_group_rules = optional(<br>        list(<br>          object({<br>            name      = string<br>            direction = string<br>            remote    = string<br>            tcp = optional(<br>              object({<br>                port_max = optional(number)<br>                port_min = optional(number)<br>              })<br>            )<br>            udp = optional(<br>              object({<br>                port_max = optional(number)<br>                port_min = optional(number)<br>              })<br>            )<br>            icmp = optional(<br>              object({<br>                type = optional(number)<br>                code = optional(number)<br>              })<br>            )<br>          })<br>        )<br>      )<br>      default_routing_table_name = optional(string)<br>      flow_logs_bucket_name      = optional(string)<br>      address_prefixes = optional(<br>        object({<br>          zone-1 = optional(list(string))<br>          zone-2 = optional(list(string))<br>          zone-3 = optional(list(string))<br>        })<br>      )<br>      network_acls = list(<br>        object({<br>          name                         = string<br>          add_ibm_cloud_internal_rules = optional(bool)<br>          add_vpc_connectivity_rules   = optional(bool)<br>          prepend_ibm_rules            = optional(bool)<br>          rules = list(<br>            object({<br>              name        = string<br>              action      = string<br>              destination = string<br>              direction   = string<br>              source      = string<br>              tcp = optional(<br>                object({<br>                  port_max        = optional(number)<br>                  port_min        = optional(number)<br>                  source_port_max = optional(number)<br>                  source_port_min = optional(number)<br>                })<br>              )<br>              udp = optional(<br>                object({<br>                  port_max        = optional(number)<br>                  port_min        = optional(number)<br>                  source_port_max = optional(number)<br>                  source_port_min = optional(number)<br>                })<br>              )<br>              icmp = optional(<br>                object({<br>                  type = optional(number)<br>                  code = optional(number)<br>                })<br>              )<br>            })<br>          )<br>        })<br>      )<br>      use_public_gateways = object({<br>        zone-1 = optional(bool)<br>        zone-2 = optional(bool)<br>        zone-3 = optional(bool)<br>      })<br>      subnets = object({<br>        zone-1 = list(object({<br>          name           = string<br>          cidr           = string<br>          public_gateway = optional(bool)<br>          acl_name       = string<br>        }))<br>        zone-2 = list(object({<br>          name           = string<br>          cidr           = string<br>          public_gateway = optional(bool)<br>          acl_name       = string<br>        }))<br>        zone-3 = list(object({<br>          name           = string<br>          cidr           = string<br>          public_gateway = optional(bool)<br>          acl_name       = string<br>        }))<br>      })<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_vpn_gateways"></a> [vpn\_gateways](#input\_vpn\_gateways) | List of VPN Gateways to create. | <pre>list(<br>    object({<br>      name           = string<br>      vpc_name       = string<br>      subnet_name    = string # Do not include prefix, use same name as in `var.subnets`<br>      mode           = optional(string)<br>      resource_group = optional(string)<br>      connections = list(<br>        object({<br>          peer_address   = string<br>          preshared_key  = string<br>          local_cidrs    = optional(list(string))<br>          peer_cidrs     = optional(list(string))<br>          admin_state_up = optional(bool)<br>        })<br>      )<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_vsi"></a> [vsi](#input\_vsi) | A list describing VSI workloads to create | <pre>list(<br>    object({<br>      name                            = string<br>      vpc_name                        = string<br>      subnet_names                    = list(string)<br>      ssh_keys                        = list(string)<br>      image_name                      = string<br>      machine_type                    = string<br>      vsi_per_subnet                  = number<br>      user_data                       = optional(string)<br>      resource_group                  = optional(string)<br>      enable_floating_ip              = optional(bool)<br>      security_groups                 = optional(list(string))<br>      boot_volume_encryption_key_name = optional(string)<br>      security_group = optional(<br>        object({<br>          name = string<br>          rules = list(<br>            object({<br>              name      = string<br>              direction = string<br>              source    = string<br>              tcp = optional(<br>                object({<br>                  port_max = number<br>                  port_min = number<br>                })<br>              )<br>              udp = optional(<br>                object({<br>                  port_max = number<br>                  port_min = number<br>                })<br>              )<br>              icmp = optional(<br>                object({<br>                  type = number<br>                  code = number<br>                })<br>              )<br>            })<br>          )<br>        })<br>      )<br>      block_storage_volumes = optional(list(<br>        object({<br>          name           = string<br>          profile        = string<br>          capacity       = optional(number)<br>          iops           = optional(number)<br>          encryption_key = optional(string)<br>        })<br>      ))<br>      load_balancers = optional(list(<br>        object({<br>          name              = string<br>          type              = string<br>          listener_port     = number<br>          listener_protocol = string<br>          connection_limit  = number<br>          algorithm         = string<br>          protocol          = string<br>          health_delay      = number<br>          health_retries    = number<br>          health_timeout    = number<br>          health_type       = string<br>          pool_member_port  = string<br>          security_group = optional(<br>            object({<br>              name = string<br>              rules = list(<br>                object({<br>                  name      = string<br>                  direction = string<br>                  source    = string<br>                  tcp = optional(<br>                    object({<br>                      port_max = number<br>                      port_min = number<br>                    })<br>                  )<br>                  udp = optional(<br>                    object({<br>                      port_max = number<br>                      port_min = number<br>                    })<br>                  )<br>                  icmp = optional(<br>                    object({<br>                      type = number<br>                      code = number<br>                    })<br>                  )<br>                })<br>              )<br>            })<br>          )<br>        })<br>      ))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_wait_till"></a> [wait\_till](#input\_wait\_till) | To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady` | `string` | `"IngressReady"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_appid_key_names"></a> [appid\_key\_names](#output\_appid\_key\_names) | List of appid key names created |
| <a name="output_appid_name"></a> [appid\_name](#output\_appid\_name) | Name of the appid instance used. |
| <a name="output_appid_redirect_urls"></a> [appid\_redirect\_urls](#output\_appid\_redirect\_urls) | List of appid redirect urls |
| <a name="output_atracker_route_name"></a> [atracker\_route\_name](#output\_atracker\_route\_name) | Name of atracker route |
| <a name="output_atracker_target_name"></a> [atracker\_target\_name](#output\_atracker\_target\_name) | Name of atracker target |
| <a name="output_bastion_host_names"></a> [bastion\_host\_names](#output\_bastion\_host\_names) | List of bastion host names |
| <a name="output_cluster_names"></a> [cluster\_names](#output\_cluster\_names) | List of create cluster names |
| <a name="output_cos_bucket_names"></a> [cos\_bucket\_names](#output\_cos\_bucket\_names) | List of names for COS buckets creaed |
| <a name="output_cos_key_names"></a> [cos\_key\_names](#output\_cos\_key\_names) | List of names for created COS keys |
| <a name="output_cos_names"></a> [cos\_names](#output\_cos\_names) | List of Cloud Object Storage instance names |
| <a name="output_f5_host_names"></a> [f5\_host\_names](#output\_f5\_host\_names) | List of bastion host names |
| <a name="output_fip_vsi_data"></a> [fip\_vsi\_data](#output\_fip\_vsi\_data) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. This list only contains instances with a floating IP attached. |
| <a name="output_resource_group_names"></a> [resource\_group\_names](#output\_resource\_group\_names) | List of resource groups names used within landing zone. |
| <a name="output_secrets_manager_name"></a> [secrets\_manager\_name](#output\_secrets\_manager\_name) | Name of secrets manager instance |
| <a name="output_security_group_names"></a> [security\_group\_names](#output\_security\_group\_names) | List of security group names |
| <a name="output_service_authorization_names"></a> [service\_authorization\_names](#output\_service\_authorization\_names) | List of service authorization names |
| <a name="output_ssh_key_names"></a> [ssh\_key\_names](#output\_ssh\_key\_names) | List of SSH key names |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | List of Subnet names created |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | Name of created transit gateway |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | List of VPC names |
| <a name="output_vpe_gateway_names"></a> [vpe\_gateway\_names](#output\_vpe\_gateway\_names) | VPE gateway names |
| <a name="output_vpn_names"></a> [vpn\_names](#output\_vpn\_names) | List of VPN names |
| <a name="output_vsi_data"></a> [vsi\_data](#output\_vsi\_data) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | List of VSI names |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
