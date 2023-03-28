##############################################################################
# Account Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowerccase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string
  default     = "land-zone-vsi-qs"

  validation {
    error_message = "Prefix must begin with a lowercase letter and contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
    condition     = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "region" {
  description = "Region where VPC will be created. To find your VPC region, use `ibmcloud is regions` command to find available regions."
  type        = string
  default     = "us-south"
}

variable "ssh_key" {
  description = "Public SSH key to use to provision a VSI. Must be a valid SSH key that does not already exist in the deployment region. See https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys."
  type        = string
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "override_json_string" {
  description = "Override default values with custom JSON. Any value here other than an empty string will override all other configuration changes."
  type        = string
  default     = <<EOF
{
   "atracker": {
      "collector_bucket_name": "atracker-bucket",
      "receive_global_events": true,
      "resource_group": "service-rg",
      "add_route": false
   },
   "clusters": [],
   "cos": [
      {
         "buckets": [
            {
               "endpoint_type": "public",
               "force_delete": true,
               "kms_key": "slz-atracker-key",
               "name": "atracker-bucket",
               "storage_class": "standard"
            }
         ],
         "keys": [
            {
               "name": "cos-bind-key",
               "role": "Writer",
               "enable_HMAC": false
            }
         ],
         "name": "atracker-cos",
         "plan": "standard",
         "resource_group": "service-rg",
         "use_data": false,
         "random_suffix": true
      },
      {
         "buckets": [
            {
               "endpoint_type": "public",
               "force_delete": true,
               "kms_key": "slz-key",
               "name": "management-bucket",
               "storage_class": "standard"
            },
            {
               "endpoint_type": "public",
               "force_delete": true,
               "kms_key": "slz-key",
               "name": "workload-bucket",
               "storage_class": "standard"
            }
         ],
         "keys": [],
         "name": "cos",
         "plan": "standard",
         "random_suffix": true,
         "resource_group": "service-rg",
         "use_data": false
      }
   ],
   "enable_transit_gateway": true,
   "key_management": {
      "keys": [
         {
            "key_ring": "slz-ring",
            "name": "slz-atracker-key",
            "root_key": true,
            "policies": {
               "rotation": {
                  "interval_month": 12
               }
            }
         },
         {
            "key_ring": "slz-ring",
            "name": "slz-key",
            "root_key": true,
            "policies": {
               "rotation": {
                  "interval_month": 12
               }
            }
         },
         {
            "key_ring": "slz-ring",
            "name": "slz-vsi-volume-key",
            "root_key": true,
            "policies": {
               "rotation": {
                  "interval_month": 12
               }
            }
         }
      ],
      "name": "slz-kms",
      "resource_group": "service-rg",
      "use_hs_crypto": false,
      "use_data": false
   },
   "network_cidr": "10.0.0.0/8",
   "resource_groups": [
      {
         "create": true,
         "name": "service-rg",
         "use_prefix": true
      },
      {
         "create": true,
         "name": "management-rg",
         "use_prefix": true
      },
      {
         "create": true,
         "name": "workload-rg",
         "use_prefix": true
      }
   ],
   "security_groups": [
    {
      "name": "management-vpe-sg",
      "resource_group": "management-rg",
      "rules": [
        {
          "direction": "inbound",
          "name": "allow-vpc-inbound",
          "source": "10.0.0.0/8"
        },
        {
          "direction": "outbound",
          "name": "allow-vpc-outbound",
          "source": "10.0.0.0/8"
        }
      ],
      "vpc_name": "management"
    },
    {
      "name": "workload-vpe-sg",
      "resource_group": "workload-rg",
      "rules": [
        {
          "direction": "inbound",
          "name": "allow-vpc-inbound",
          "source": "10.0.0.0/8"
        },
        {
          "direction": "outbound",
          "name": "allow-vpc-outbound",
          "source": "10.0.0.0/8"
        }
      ],
      "vpc_name": "workload"
    }
   ],
   "transit_gateway_connections": [
      "management",
      "workload"
   ],
   "transit_gateway_resource_group": "service-rg",
   "virtual_private_endpoints": [
      {
         "service_name": "cos",
         "service_type": "cloud-object-storage",
         "resource_group": "service-rg",
         "vpcs": [
            {
               "name": "management",
               "security_group_name": "management-vpe-sg",
               "subnets": [
                  "vpe-zone-1"
               ]
            },
            {
               "name": "workload",
               "security_group_name": "workload-vpe-sg",
               "subnets": [
                  "vpe-zone-1"
               ]
            }
         ]
      }
   ],
   "vpcs": [
      {
         "flow_logs_bucket_name": null,
         "classic_access": false,
         "default_network_acl_name": null,
         "default_routing_table_name": null,
         "default_security_group_name": null,
         "default_security_group_rules": [],
         "use_manual_address_prefixes": true,
         "network_acls": [
            {
               "add_cluster_rules": false,
               "name": "management-acl",
               "rules": [
                  {
                     "name": "allow-ssh-inbound",
                     "action": "allow",
                     "direction": "inbound",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": 22,
                        "port_max": 22,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "source": "0.0.0.0/0",
                     "destination": "10.0.0.0/8"
                  },
                  {
                     "action": "allow",
                     "destination": "10.0.0.0/8",
                     "direction": "inbound",
                     "name": "allow-ibm-inbound",
                     "source": "161.26.0.0/16",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     }
                  },
                  {
                     "action": "allow",
                     "destination": "10.0.0.0/8",
                     "direction": "inbound",
                     "name": "allow-all-network-inbound",
                     "source": "10.0.0.0/8",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     }
                  },
                  {
                     "action": "allow",
                     "destination": "0.0.0.0/0",
                     "direction": "outbound",
                     "name": "allow-all-outbound",
                     "source": "0.0.0.0/0",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     }
                  }
               ]
            }
         ],
         "prefix": "management",
         "resource_group": "management-rg",
         "subnets": {
            "zone-1": [
               {
                  "acl_name": "management-acl",
                  "cidr": "10.10.10.0/24",
                  "name": "vsi-zone-1",
                  "public_gateway": false
               },
               {
                  "acl_name": "management-acl",
                  "cidr": "10.10.20.0/24",
                  "name": "vpe-zone-1",
                  "public_gateway": false
               }
            ],
            "zone-2": [],
            "zone-3": []
         },
         "use_public_gateways": {
            "zone-1": false,
            "zone-2": false,
            "zone-3": false
         }
      },
      {
         "classic_access": false,
         "default_network_acl_name": null,
         "default_routing_table_name": null,
         "default_security_group_name": null,
         "default_security_group_rules": [],
         "use_manual_address_prefixes": true,
         "flow_logs_bucket_name": null,
         "network_acls": [
            {
               "add_cluster_rules": false,
               "name": "workload-acl",
               "rules": [
                  {
                     "action": "allow",
                     "destination": "10.0.0.0/8",
                     "direction": "inbound",
                     "name": "allow-ibm-inbound",
                     "source": "161.26.0.0/16",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     }
                  },
                  {
                     "action": "allow",
                     "destination": "10.0.0.0/8",
                     "direction": "inbound",
                     "name": "allow-all-network-inbound",
                     "source": "10.0.0.0/8",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     }
                  },
                  {
                     "action": "allow",
                     "destination": "0.0.0.0/0",
                     "direction": "outbound",
                     "name": "allow-all-outbound",
                     "source": "0.0.0.0/0",
                     "icmp": {
                        "type": null,
                        "code": null
                     },
                     "tcp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     },
                     "udp": {
                        "port_min": null,
                        "port_max": null,
                        "source_port_min": null,
                        "source_port_max": null
                     }
                  }
               ]
            }
         ],
         "prefix": "workload",
         "resource_group": "workload-rg",
         "subnets": {
            "zone-1": [
               {
                  "acl_name": "workload-acl",
                  "cidr": "10.40.10.0/24",
                  "name": "vsi-zone-1",
                  "public_gateway": false
               },
               {
                  "acl_name": "workload-acl",
                  "cidr": "10.40.20.0/24",
                  "name": "vpe-zone-1",
                  "public_gateway": false
               }
            ],
            "zone-2": [],
            "zone-3": []
         },
         "use_public_gateways": {
            "zone-1": false,
            "zone-2": false,
            "zone-3": false
         }
      }
   ],
   "vpn_gateways": [],
   "vsi": [
      {
         "boot_volume_encryption_key_name": "slz-vsi-volume-key",
         "image_name": "ibm-ubuntu-22-04-1-minimal-amd64-4",
         "machine_type": "cx2-4x8",
         "name": "jump-box",
         "resource_group": "management-rg",
         "security_group": {
            "name": "management",
            "rules": [
               {
                  "name": "allow-ssh-inbound",
                  "direction": "inbound",
                  "icmp": {
                     "type": null,
                     "code": null
                  },
                  "tcp": {
                     "port_min": 22,
                     "port_max": 22
                  },
                  "udp": {
                     "port_min": null,
                     "port_max": null
                  },
                  "source": "0.0.0.0/0"
               },
               {
                  "direction": "inbound",
                  "name": "allow-ibm-inbound",
                  "source": "161.26.0.0/16",
                  "tcp": {
                     "port_max": null,
                     "port_min": null
                  },
                  "icmp": {
                     "code": null,
                     "type": null
                  },
                  "udp": {
                     "port_max": null,
                     "port_min": null
                  }
               },
               {
                  "direction": "inbound",
                  "name": "allow-vpc-inbound",
                  "source": "10.0.0.0/8",
                  "tcp": {
                     "port_max": null,
                     "port_min": null
                  },
                  "icmp": {
                     "code": null,
                     "type": null
                  },
                  "udp": {
                     "port_max": null,
                     "port_min": null
                  }
               },
               {
                  "direction": "outbound",
                  "name": "allow-all-outbound",
                  "source": "0.0.0.0/0",
                  "tcp": {
                     "port_min": null,
                     "port_max": null
                  },
                  "icmp": {
                     "type": null,
                     "code": null
                  },
                  "udp": {
                     "port_min": null,
                     "port_max": null
                  }
               }
            ]
         },
         "ssh_keys": [
            "ssh-key"
         ],
         "subnet_names": [
            "vsi-zone-1"
         ],
         "vpc_name": "management",
         "vsi_per_subnet": 1,
         "security_groups": [],
         "user_data": "",
         "subnet_name": "",
         "enable_floating_ip": true
      },
      {
         "boot_volume_encryption_key_name": "slz-vsi-volume-key",
         "image_name": "ibm-ubuntu-22-04-1-minimal-amd64-4",
         "machine_type": "cx2-4x8",
         "name": "workload-server",
         "resource_group": "workload-rg",
         "security_group": {
            "name": "workload",
            "rules": [
               {
                  "direction": "inbound",
                  "name": "allow-ibm-inbound",
                  "source": "161.26.0.0/16",
                  "tcp": {
                     "port_max": null,
                     "port_min": null
                  },
                  "icmp": {
                     "code": null,
                     "type": null
                  },
                  "udp": {
                     "port_max": null,
                     "port_min": null
                  }
               },
               {
                  "direction": "inbound",
                  "name": "allow-vpc-inbound",
                  "source": "10.0.0.0/8",
                  "tcp": {
                     "port_max": null,
                     "port_min": null
                  },
                  "icmp": {
                     "code": null,
                     "type": null
                  },
                  "udp": {
                     "port_max": null,
                     "port_min": null
                  }
               },
               {
                  "direction": "outbound",
                  "name": "allow-all-outbound",
                  "source": "0.0.0.0/0",
                  "tcp": {
                     "port_min": null,
                     "port_max": null
                  },
                  "icmp": {
                     "type": null,
                     "code": null
                  },
                  "udp": {
                     "port_min": null,
                     "port_max": null
                  }
               }
            ]
         },
         "ssh_keys": [
            "ssh-key"
         ],
         "subnet_names": [
            "vsi-zone-1"
         ],
         "vpc_name": "workload",
         "vsi_per_subnet": 1,
         "security_groups": [],
         "enable_floating_ip": false,
         "user_data": "",
         "subnet_name": ""
      }
   ],
   "wait_till": "IngressReady"
}
EOF
}
