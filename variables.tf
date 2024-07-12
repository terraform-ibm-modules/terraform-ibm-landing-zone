##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources that is prepended to resources that are provisioned. Must begin with a lowercase letter and end with a lowercase letter or number. Must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix))
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
}

variable "tags" {
  description = "List of resource tags to apply to resources created by this module."
  type        = list(string)
  default     = []
}

##############################################################################


##############################################################################
# Resource Groups Variables
##############################################################################

variable "resource_groups" {
  description = "Object describing resource groups to create or reference"
  type = list(
    object({
      name       = string
      create     = optional(bool)
      use_prefix = optional(bool)
    })
  )

  validation {
    error_message = "Each group must have a unique name."
    condition     = length(distinct(var.resource_groups[*].name)) == length(var.resource_groups[*].name)
  }
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable "network_cidr" {
  description = "Network CIDR for the VPC. This is used to manage network ACL rules for cluster provisioning."
  type        = string
  default     = "10.0.0.0/8"
}

variable "vpcs" {
  description = "A map describing VPCs to be created in this repo."
  type = list(
    object({
      prefix          = string # VPC prefix
      existing_vpc_id = optional(string)
      existing_subnets = optional(
        list(
          object({
            id             = string
            public_gateway = optional(bool, false)
          })
        )
      )
      resource_group                    = optional(string) # Name of the group where VPC will be created
      access_tags                       = optional(list(string), [])
      classic_access                    = optional(bool)
      default_network_acl_name          = optional(string)
      default_security_group_name       = optional(string)
      clean_default_sg_acl              = optional(bool, false)
      dns_binding_name                  = optional(string, null)
      dns_instance_name                 = optional(string, null)
      dns_custom_resolver_name          = optional(string, null)
      dns_location                      = optional(string, "global")
      dns_plan                          = optional(string, "standard-dns")
      existing_dns_instance_id          = optional(string, null)
      use_existing_dns_instance         = optional(bool, false)
      enable_hub                        = optional(bool, false)
      skip_spoke_auth_policy            = optional(bool, false)
      hub_account_id                    = optional(string, null)
      enable_hub_vpc_id                 = optional(bool, false)
      hub_vpc_id                        = optional(string, null)
      enable_hub_vpc_crn                = optional(bool, false)
      hub_vpc_crn                       = optional(string, null)
      update_delegated_resolver         = optional(bool, false)
      skip_custom_resolver_hub_creation = optional(bool, false)
      resolver_type                     = optional(string, null)
      manual_servers = optional(list(object({
        address       = string
        zone_affinity = optional(string)
      })), [])
      default_security_group_rules = optional(
        list(
          object({
            name      = string
            direction = string
            remote    = string
            tcp = optional(
              object({
                port_max = optional(number)
                port_min = optional(number)
              })
            )
            udp = optional(
              object({
                port_max = optional(number)
                port_min = optional(number)
              })
            )
            icmp = optional(
              object({
                type = optional(number)
                code = optional(number)
              })
            )
          })
        )
      )
      default_routing_table_name = optional(string)
      flow_logs_bucket_name      = optional(string)
      address_prefixes = optional(
        object({
          zone-1 = optional(list(string))
          zone-2 = optional(list(string))
          zone-3 = optional(list(string))
        })
      )
      network_acls = list(
        object({
          name                         = string
          add_ibm_cloud_internal_rules = optional(bool)
          add_vpc_connectivity_rules   = optional(bool)
          prepend_ibm_rules            = optional(bool)
          rules = list(
            object({
              name        = string
              action      = string
              destination = string
              direction   = string
              source      = string
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
          )
        })
      )
      use_public_gateways = object({
        zone-1 = optional(bool)
        zone-2 = optional(bool)
        zone-3 = optional(bool)
      })
      subnets = optional(object({
        zone-1 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
          no_addr_prefix = optional(bool, false)
        }))
        zone-2 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
          no_addr_prefix = optional(bool, false)
        }))
        zone-3 = list(object({
          name           = string
          cidr           = string
          public_gateway = optional(bool)
          acl_name       = string
          no_addr_prefix = optional(bool, false)
        }))
      }))
    })
  )
}

variable "vpn_gateways" {
  description = "List of VPN Gateways to create."
  type = list(
    object({
      name           = string
      vpc_name       = string
      subnet_name    = string # Do not include prefix, use same name as in `var.subnets`
      mode           = optional(string)
      resource_group = optional(string)
      access_tags    = optional(list(string), [])
    })
  )
}

##############################################################################


##############################################################################
# Transit Gateway
##############################################################################

variable "enable_transit_gateway" {
  description = "Create transit gateway"
  type        = bool
  default     = true
}

variable "transit_gateway_global" {
  description = "Connect to the networks outside the associated region. Will only be used if transit gateway is enabled."
  type        = bool
  default     = false
}

variable "transit_gateway_resource_group" {
  description = "Name of resource group to use for transit gateway. Must be included in `var.resource_group`"
  type        = string
}

variable "transit_gateway_connections" {
  description = "Transit gateway vpc connections. Will only be used if transit gateway is enabled."
  type        = list(string)
}

##############################################################################

##############################################################################
# VSI Variables
##############################################################################

variable "ssh_keys" {
  description = "SSH keys to use to provision a VSI. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). If `public_key` is not provided, the named key will be looked up from data. If a resource group name is added, it must be included in `var.resource_groups`. See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys."
  type = list(
    object({
      name           = string
      public_key     = optional(string)
      resource_group = optional(string)
    })
  )

  validation {
    error_message = "Each SSH key must have a unique name."
    condition     = length(distinct(var.ssh_keys[*].name)) == length(var.ssh_keys[*].name)
  }

  validation {
    error_message = "Each key using the public_key field must have a unique public key."
    condition = length(
      distinct(
        [
          for ssh_key in var.ssh_keys :
          ssh_key.public_key if lookup(ssh_key, "public_key", null) != null
        ]
      )
      ) == length(
      [
        for ssh_key in var.ssh_keys :
        ssh_key.public_key if lookup(ssh_key, "public_key", null) != null
      ]
    )
  }
}

variable "vsi" {
  description = "A list describing VSI workloads to create"
  type = list(
    object({
      name                            = string
      vpc_name                        = string
      subnet_names                    = list(string)
      ssh_keys                        = list(string)
      image_name                      = string
      machine_type                    = string
      vsi_per_subnet                  = number
      user_data                       = optional(string)
      resource_group                  = optional(string)
      enable_floating_ip              = optional(bool)
      security_groups                 = optional(list(string))
      boot_volume_encryption_key_name = optional(string)
      access_tags                     = optional(list(string), [])
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
      block_storage_volumes = optional(list(
        object({
          name           = string
          profile        = string
          capacity       = optional(number)
          iops           = optional(number)
          encryption_key = optional(string)
        })
      ))
      load_balancers = optional(list(
        object({
          name                    = string
          type                    = string
          listener_port           = number
          listener_protocol       = string
          connection_limit        = number
          algorithm               = string
          protocol                = string
          health_delay            = number
          health_retries          = number
          health_timeout          = number
          health_type             = string
          pool_member_port        = string
          idle_connection_timeout = optional(number)
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
        })
      ))
    })
  )
}

##############################################################################


##############################################################################
# Security Group Variables
##############################################################################

variable "security_groups" {
  description = "Security groups for VPC"
  type = list(
    object({
      name           = string
      vpc_name       = string
      resource_group = optional(string)
      access_tags    = optional(list(string), [])
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

  default = []

  validation {
    error_message = "Each security group rule must have a unique name."
    condition = length([
      for security_group in var.security_groups :
      true if length(distinct(security_group.rules[*].name)) != length(security_group.rules[*].name)
    ]) == 0
  }

  validation {
    error_message = "Security group rule direction can only be `inbound` or `outbound`."
    condition = length(
      [
        for group in var.security_groups :
        true if length(
          distinct(
            flatten([
              for rule in group.rules :
              false if !contains(["inbound", "outbound"], rule.direction)
            ])
          )
        ) != 0
      ]
    ) == 0
  }

}

##############################################################################


##############################################################################
# VPE Variables
##############################################################################

variable "virtual_private_endpoints" {
  description = "Object describing VPE to be created"
  type = list(
    object({
      service_name   = string
      service_type   = string
      resource_group = optional(string)
      access_tags    = optional(list(string), [])
      vpcs = list(
        object({
          name                = string
          subnets             = list(string)
          security_group_name = optional(string)
        })
      )
    })
  )
}

##############################################################################


##############################################################################
# Cloud Object Storage Variables
##############################################################################

variable "cos" {
  description = "Object describing the cloud object storage instance, buckets, and keys. Set `use_data` to false to create instance"
  type = list(
    object({
      name           = string
      use_data       = optional(bool)
      resource_group = string
      plan           = optional(string)
      random_suffix  = optional(bool) # Use a random suffix for COS instance
      access_tags    = optional(list(string), [])
      buckets = list(object({
        name                  = string
        storage_class         = string
        endpoint_type         = string
        force_delete          = bool
        single_site_location  = optional(string)
        region_location       = optional(string)
        cross_region_location = optional(string)
        kms_key               = optional(string)
        access_tags           = optional(list(string), [])
        allowed_ip            = optional(list(string), [])
        hard_quota            = optional(number)
        archive_rule = optional(object({
          days    = number
          enable  = bool
          rule_id = optional(string)
          type    = string
        }))
        expire_rule = optional(object({
          days                         = optional(number)
          date                         = optional(string)
          enable                       = bool
          expired_object_delete_marker = optional(string)
          prefix                       = optional(string)
          rule_id                      = optional(string)
        }))
        activity_tracking = optional(object({
          activity_tracker_crn = string
          read_data_events     = bool
          write_data_events    = bool
        }))
        metrics_monitoring = optional(object({
          metrics_monitoring_crn  = string
          request_metrics_enabled = optional(bool)
          usage_metrics_enabled   = optional(bool)
        }))
      }))
      keys = optional(
        list(object({
          name        = string
          role        = string
          enable_HMAC = bool
        }))
      )

    })
  )

  validation {
    error_message = "Each COS key must have a unique name."
    condition = length(
      flatten(
        [
          for instance in var.cos :
          [
            for keys in instance.keys :
            keys.name
          ] if lookup(instance, "keys", false) != false
        ]
      )
      ) == length(
      distinct(
        flatten(
          [
            for instance in var.cos :
            [
              for keys in instance.keys :
              keys.name
            ] if lookup(instance, "keys", false) != false
          ]
        )
      )
    )
  }

  validation {
    error_message = "Plans for COS instances can only be `lite` or `standard`."
    condition = length([
      for instance in var.cos :
      true if contains(["lite", "standard"], instance.plan)
    ]) == length(var.cos)
  }

  validation {
    error_message = "COS Bucket names must be unique."
    condition = length(
      flatten([
        for instance in var.cos :
        instance.buckets[*].name
      ])
      ) == length(
      distinct(
        flatten([
          for instance in var.cos :
          instance.buckets[*].name
        ])
      )
    )
  }

  # https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-classes
  validation {
    error_message = "Storage class can only be `standard`, `vault`, `cold`, or `smart`."
    condition = length(
      flatten(
        [
          for instance in var.cos :
          [
            for bucket in instance.buckets :
            true if contains(["standard", "vault", "cold", "smart"], bucket.storage_class)
          ]
        ]
      )
    ) == length(flatten([for instance in var.cos : [for bucket in instance.buckets : true]]))
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#endpoint_type
  validation {
    error_message = "Endpoint type can only be `public`, `private`, or `direct`."
    condition = length(
      flatten(
        [
          for instance in var.cos :
          [
            for bucket in instance.buckets :
            true if contains(["public", "private", "direct"], bucket.endpoint_type)
          ]
        ]
      )
    ) == length(flatten([for instance in var.cos : [for bucket in instance.buckets : true]]))
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#single_site_location
  validation {
    error_message = "All single site buckets must specify `ams03`, `che01`, `hkg02`, `mel01`, `mex01`, `mil01`, `mon01`, `osl01`, `par01`, `sjc04`, `sao01`, `seo01`, `sng01`, or `tor01`."
    condition = length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "single_site_location", null) != null
            ]
          ]
        ) : site_bucket if !contains(["ams03", "che01", "hkg02", "mel01", "mex01", "mil01", "mon01", "osl01", "par01", "sjc04", "sao01", "seo01", "sng01", "tor01"], site_bucket.single_site_location)
      ]
    ) == 0
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#region_location
  validation {
    error_message = "All regional buckets must specify `au-syd`, `eu-de`, `eu-es`, `eu-gb`, `eu-fr2`, `jp-tok`, `us-east`, `us-south`, `ca-tor`, `jp-osa`, `br-sao`."
    condition = length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "region_location", null) != null
            ]
          ]
        ) : site_bucket if !contains(["au-syd", "eu-de", "eu-es", "eu-gb", "eu-fr2", "jp-tok", "us-east", "us-south", "ca-tor", "jp-osa", "br-sao"], site_bucket.region_location)
      ]
    ) == 0
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#cross_region_location
  validation {
    error_message = "All cross-regional buckets must specify `us`, `eu`, `ap`."
    condition = length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "cross_region_location", null) != null
            ]
          ]
        ) : site_bucket if !contains(["us", "eu", "ap"], site_bucket.cross_region_location)
      ]
    ) == 0
  }

  # https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/cos_bucket#archive_rule
  validation {
    error_message = "Each archive rule must specify a type of `Glacier` or `Accelerated`."
    condition = length(
      [
        for site_bucket in flatten(
          [
            for instance in var.cos :
            [
              for bucket in instance.buckets :
              bucket if lookup(bucket, "archive_rule", null) != null
            ]
          ]
        ) : site_bucket if !contains(["Glacier", "Accelerated"], site_bucket.archive_rule.type)
      ]
    ) == 0
  }
}

##############################################################################


##############################################################################
# Service Instance Variables
##############################################################################

variable "service_endpoints" {
  description = "Service endpoints for the App ID resource when created by the module. Can be `public`, `private`, or `public-and-private`"
  type        = string
  default     = "public-and-private"

  validation {
    error_message = "Service endpoints can only be `public`, `private`, or `public-and-private`."
    condition     = contains(["public", "private", "public-and-private"], var.service_endpoints)
  }
}

variable "key_management" {
  description = "Key Protect instance variables"
  type = object({
    name              = optional(string)
    resource_group    = optional(string)
    use_data          = optional(bool)
    use_hs_crypto     = optional(bool)
    access_tags       = optional(list(string), [])
    service_endpoints = optional(string, "public-and-private")
    keys = optional(
      list(
        object({
          name             = string
          root_key         = optional(bool)
          payload          = optional(string)
          key_ring         = optional(string) # Any key_ring added will be created
          force_delete     = optional(bool)
          existing_key_crn = optional(string) # CRN of an existing key in the same or different account.
          endpoint         = optional(string) # can be public or private
          iv_value         = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
          encrypted_nonce  = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
          policies = optional(
            object({
              rotation = optional(
                object({
                  interval_month = number
                })
              )
              dual_auth_delete = optional(
                object({
                  enabled = bool
                })
              )
            })
          )
        })
      )
    )
  })
  validation {
    error_message = "Name must be included if use_data is true."
    condition = (
      lookup(var.key_management, "use_data", null) == null
      ) || (
      lookup(var.key_management, "use_data", false) == false
      ) || (
      lookup(var.key_management, "name", null) != null &&
      lookup(var.key_management, "use_data", false) == true
    )
  }
  validation {
    error_message = "Name must be included if use_hs_crypto is true."
    condition = (
      lookup(var.key_management, "use_hs_crypto", null) == null
      ) || (
      lookup(var.key_management, "use_hs_crypto", false) == false
      ) || (
      lookup(var.key_management, "name", null) != null &&
      lookup(var.key_management, "use_hs_crypto", false) == true
    )
  }
  validation {
    condition     = length(flatten([for key in var.key_management.keys : key if(lookup(key, "existing_key_crn", null) == null) && var.key_management.name == null])) == 0
    error_message = "Please provide kms name to be created."
  }
  validation {
    condition     = contains(["private", "public-and-private"], var.key_management.service_endpoints)
    error_message = "KMS Service Endpoint must be one of: private, public-and-private"
  }
}

##############################################################################


##############################################################################
# atracker variables
##############################################################################

variable "atracker" {
  description = "atracker variables"
  type = object({
    resource_group        = string
    receive_global_events = bool
    collector_bucket_name = string
    add_route             = bool
  })
}

##############################################################################

##############################################################################
# Cluster variables
##############################################################################

variable "clusters" {
  description = "A list describing clusters workloads to create"
  type = list(
    object({
      name                                = string           # Name of Cluster
      vpc_name                            = string           # Name of VPC
      subnet_names                        = list(string)     # List of vpc subnets for cluster
      workers_per_subnet                  = number           # Worker nodes per subnet.
      machine_type                        = string           # Worker node flavor
      kube_type                           = string           # iks or openshift
      kube_version                        = optional(string) # Can be a version from `ibmcloud ks versions` or `default`
      entitlement                         = optional(string) # entitlement option for openshift
      secondary_storage                   = optional(string) # Secondary storage type
      pod_subnet                          = optional(string) # Portable subnet for pods
      service_subnet                      = optional(string) # Portable subnet for services
      resource_group                      = string           # Resource Group used for cluster
      cos_name                            = optional(string) # Name of COS instance Required only for OpenShift clusters
      access_tags                         = optional(list(string), [])
      boot_volume_crk_name                = optional(string)      # Boot volume encryption key name
      disable_public_endpoint             = optional(bool, true)  # disable cluster public, leaving only private endpoint
      disable_outbound_traffic_protection = optional(bool, false) # public outbound access from the cluster workers
      cluster_force_delete_storage        = optional(bool, false) # force the removal of persistent storage associated with the cluster during cluster deletion
      kms_wait_for_apply                  = optional(bool, true)  # make terraform wait until KMS is applied to master and it is ready and deployed
      addons = optional(object({                                  # Map of OCP cluster add-on versions to install
        debug-tool                = optional(string)
        image-key-synchronizer    = optional(string)
        openshift-data-foundation = optional(string)
        vpc-file-csi-driver       = optional(string)
        static-route              = optional(string)
        cluster-autoscaler        = optional(string)
        vpc-block-csi-driver      = optional(string)
        ibm-storage-operator      = optional(string)
      }), {})
      manage_all_addons = optional(bool, false) # Instructs Terraform to manage all cluster addons, even if addons were installed outside of the module. If set to 'true' this module will destroy any addons that were installed by other sources.
      kms_config = optional(
        object({
          crk_name         = string         # Name of key
          private_endpoint = optional(bool) # Private endpoint
        })
      )
      worker_pools = optional(
        list(
          object({
            name                 = string           # Worker pool name
            vpc_name             = string           # VPC name
            workers_per_subnet   = number           # Worker nodes per subnet
            flavor               = string           # Worker node flavor
            subnet_names         = list(string)     # List of vpc subnets for worker pool
            entitlement          = optional(string) # entitlement option for openshift
            secondary_storage    = optional(string) # Secondary storage type
            boot_volume_crk_name = optional(string) # Boot volume encryption key name
          })
        )
      )
    })
  )

  # kube_type validation
  validation {
    condition     = length([for type in flatten(var.clusters[*].kube_type) : true if type == "iks" || type == "openshift"]) == length(var.clusters)
    error_message = "Invalid value for kube_type entered. Valid values are `iks` or `openshift`."
  }

  # openshift clusters must have cos name
  validation {
    error_message = "OpenShift clusters must have a cos name associated with them for provision."
    condition = length([
      for openshift_cluster in [
        for cluster in var.clusters :
        cluster if cluster.kube_type == "openshift"
      ] : openshift_cluster if openshift_cluster.cos_name == null
    ]) == 0
  }

  # subnet_names validation
  validation {
    condition     = length([for subnet in(var.clusters[*].subnet_names) : false if length(distinct(subnet)) != length(subnet)]) == 0
    error_message = "Duplicates in var.clusters.subnet_names list. Please provide unique subnet list."
  }

  # cluster name validation
  validation {
    condition     = length(distinct([for name in flatten(var.clusters[*].name) : name])) == length(flatten(var.clusters[*].name))
    error_message = "Duplicate cluster name. Please provide unique cluster names."
  }

  # min. workers_per_subnet=2 (default pool) for openshift validation
  validation {
    condition     = length([for n in flatten(var.clusters[*]) : false if(n.kube_type == "openshift" && (length(n.subnet_names) * n.workers_per_subnet < 2))]) == 0
    error_message = "For openshift cluster workers needs to be 2 or more."
  }

  # worker_pool name validation
  validation {
    condition     = length([for pools in([for worker_pool in var.clusters[*].worker_pools : worker_pool if worker_pool != null]) : false if(length(distinct([for pool in pools : pool.name])) != length([for pool in pools : pool.name]))]) == 0
    error_message = "Duplicate worker_pool name in list var.cluster.worker_pools. Please provide unique worker_pool names."
  }

}

variable "wait_till" {
  description = "To avoid long wait times when you run your Terraform code, you can specify the stage when you want Terraform to mark the cluster resource creation as completed. Depending on what stage you choose, the cluster creation might not be fully completed and continues to run in the background. However, your Terraform code can continue to run without waiting for the cluster to be fully created. Supported args are `MasterNodeReady`, `OneWorkerNodeReady`, and `IngressReady`"
  type        = string
  default     = "IngressReady"

  validation {
    error_message = "`wait_till` value must be one of `MasterNodeReady`, `OneWorkerNodeReady`, or `IngressReady`."
    condition = contains([
      "MasterNodeReady",
      "OneWorkerNodeReady",
      "IngressReady"
    ], var.wait_till)
  }
}

##############################################################################

##############################################################################
# App ID Variables
##############################################################################

variable "appid" {
  description = "The App ID instance to be used for the teleport vsi deployments"
  type = object({
    name           = optional(string)
    resource_group = optional(string)
    use_data       = optional(bool)
    keys           = optional(list(string))
    use_appid      = bool
  })
  default = {
    use_appid = false
  }

  validation {
    error_message = "Name must be included if use_appid is true."
    condition = (
      var.appid["use_appid"] == false
      ) || (
      lookup(var.appid, "name", null) != null &&
      var.appid["use_appid"] == true
    )
  }

  # app id key validation
  validation {
    condition = lookup(var.appid, "keys", null) == null || (
      length(
        lookup(var.appid, "keys", null) == null ? [] : var.appid["keys"]
        ) == length(
        distinct(
          lookup(var.appid, "keys", null) == null ? [] : var.appid["keys"]
        )
      )
    )
    error_message = "Duplicate appid key. Please provide unique appid keys."
  }
}

##############################################################################

##############################################################################
# Bastion Host Variables
##############################################################################

variable "teleport_config_data" {
  description = "Teleport config data. This is used to create a single template for all teleport instances to use. Creating a single template allows for values to remain sensitive"
  type = object({
    teleport_license   = optional(string)
    https_cert         = optional(string)
    https_key          = optional(string)
    domain             = optional(string)
    cos_bucket_name    = optional(string)
    cos_key_name       = optional(string)
    teleport_version   = optional(string)
    message_of_the_day = optional(string)
    hostname           = optional(string)
    app_id_key_name    = optional(string)
    claims_to_roles = optional(
      list(
        object({
          email = string
          roles = list(string)
        })
      )
    )
  })
  sensitive = true
  default   = null
}

variable "teleport_vsi" {
  description = "A list of teleport vsi deployments"
  type = list(
    object(
      {
        name                            = string
        vpc_name                        = string
        resource_group                  = optional(string)
        subnet_name                     = string
        ssh_keys                        = list(string)
        boot_volume_encryption_key_name = string
        image_name                      = string
        machine_type                    = string
        access_tags                     = optional(list(string), [])
        security_groups                 = optional(list(string))
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


      }
    )
  )
  default = []
  # vsi name validation
  validation {
    condition     = length(distinct([for name in flatten(var.teleport_vsi[*].name) : name])) == length(flatten(var.teleport_vsi[*].name))
    error_message = "Duplicate teleport_vsi name. Please provide unique teleport_vsi names."
  }
}

##############################################################################


#############################################################################
# F5 Variables
##############################################################################

variable "f5_vsi" {
  description = "A list describing F5 VSI workloads to create"
  type = list(
    object({
      name                   = string
      vpc_name               = string
      primary_subnet_name    = string
      secondary_subnet_names = list(string)
      secondary_subnet_security_group_names = list(
        object({
          group_name     = string
          interface_name = string
        })
      )
      ssh_keys                        = list(string)
      f5_image_name                   = string
      machine_type                    = string
      resource_group                  = optional(string)
      enable_management_floating_ip   = optional(bool)
      enable_external_floating_ip     = optional(bool)
      security_groups                 = optional(list(string))
      boot_volume_encryption_key_name = optional(string)
      hostname                        = string
      domain                          = string
      access_tags                     = optional(list(string), [])
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
      block_storage_volumes = optional(list(
        object({
          name           = string
          profile        = string
          capacity       = optional(number)
          iops           = optional(number)
          encryption_key = optional(string)
        })
      ))
      load_balancers = optional(list(
        object({
          name                    = string
          type                    = string
          listener_port           = number
          listener_protocol       = string
          connection_limit        = number
          algorithm               = string
          protocol                = string
          health_delay            = number
          health_retries          = number
          health_timeout          = number
          health_type             = string
          pool_member_port        = string
          idle_connection_timeout = optional(number)
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
        })
      ))
    })
  )
  default = []

  validation {
    error_message = "Image names for F5 VSI must be one of [`f5-bigip-15-1-5-1-0-0-14-all-1slot`,`f5-bigip-15-1-5-1-0-0-14-ltm-1slot`, `f5-bigip-16-1-2-2-0-0-28-ltm-1slot`,`f5-bigip-16-1-2-2-0-0-28-all-1slot`]."
    condition = length(
      [
        for f5_vsi in var.f5_vsi :
        f5_vsi if !contains(
          [
            "f5-bigip-15-1-5-1-0-0-14-all-1slot",
            "f5-bigip-15-1-5-1-0-0-14-ltm-1slot",
            "f5-bigip-16-1-2-2-0-0-28-ltm-1slot",
            "f5-bigip-16-1-2-2-0-0-28-all-1slot",
            "f5-bigip-16-1-3-2-0-0-4-ltm-1slot",
            "f5-bigip-16-1-3-2-0-0-4-all-1slot",
            "f5-bigip-17-0-0-1-0-0-4-ltm-1slot",
            "f5-bigip-17-0-0-1-0-0-4-all-1slot"
          ],
          f5_vsi.f5_image_name
        )
      ]
    ) == 0
  }
}

variable "f5_template_data" {
  description = "Data for all f5 templates"
  sensitive   = true
  type = object({
    tmos_admin_password     = optional(string)
    license_type            = optional(string)
    byol_license_basekey    = optional(string)
    license_host            = optional(string)
    license_username        = optional(string)
    license_password        = optional(string)
    license_pool            = optional(string)
    license_sku_keyword_1   = optional(string)
    license_sku_keyword_2   = optional(string)
    license_unit_of_measure = optional(string)
    do_declaration_url      = optional(string)
    as3_declaration_url     = optional(string)
    ts_declaration_url      = optional(string)
    phone_home_url          = optional(string)
    template_source         = optional(string)
    template_version        = optional(string)
    app_id                  = optional(string)
    tgactive_url            = optional(string)
    tgstandby_url           = optional(string)
    tgrefresh_url           = optional(string)
  })
  default = {
    license_type = "none"
  }

  validation {
    error_message = "Value for tmos_password must be at least 15 characters, contain one numeric, one uppercase, and one lowercase character."
    condition = var.f5_template_data["tmos_admin_password"] == null ? true : (
      length(var.f5_template_data.tmos_admin_password) >= 15
      && can(regex("[A-Z]", var.f5_template_data.tmos_admin_password))
      && can(regex("[a-z]", var.f5_template_data.tmos_admin_password))
      && can(regex("[0-9]", var.f5_template_data.tmos_admin_password))
    )
  }
}

##############################################################################

##############################################################################
# VPC Placement Group Variable
##############################################################################

variable "vpc_placement_groups" {
  description = "List of VPC placement groups to create"
  type = list(
    object({
      access_tags    = optional(list(string), [])
      name           = string
      resource_group = optional(string)
      strategy       = string
    })
  )
  default = []

  validation {
    error_message = "Each VPC Placement group must have a unique name."
    condition     = length(var.vpc_placement_groups) == 0 ? true : length(var.vpc_placement_groups[*].name) == length(distinct(var.vpc_placement_groups[*].name))
  }

  validation {
    error_message = "Each placement group must have a strategy of either `host_spread` or `power_spread`."
    condition = length(var.vpc_placement_groups) == 0 ? true : length([
      for group in var.vpc_placement_groups :
      false if group.strategy != "host_spread" && group.strategy != "power_spread"
    ]) == 0
  }
}

##############################################################################

##############################################################################
# s2s variables
##############################################################################

variable "skip_kms_block_storage_s2s_auth_policy" {
  description = "Whether to skip the creation of a service-to-service authorization policy between block storage and the key management service."
  type        = bool
  default     = false
}

variable "skip_all_s2s_auth_policies" {
  description = "Whether to skip the creation of all of the service-to-service authorization policies. If setting to true, policies must be in place on the account before provisioning."
  type        = bool
  default     = false
}

##############################################################################
