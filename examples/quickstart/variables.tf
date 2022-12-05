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
   "access_groups": [],
   "appid": {
      "keys": [
         "slz-appid-key"
      ],
      "name": "slz-appid",
      "resource_group": "slz-service-rg",
      "use_appid": false,
      "use_data": false
   },
   "clusters": [],
   "enable_transit_gateway": true,
   "transit_gateway_connections": [
      "management",
      "workload"
   ],
   "transit_gateway_resource_group": "slz-service-rg",
   "virtual_private_endpoints": [
      {
         "resource_group": "slz-service-rg",
         "service_name": "cos",
         "service_type": "cloud-object-storage",
         "vpcs": [
            {
               "name": "management",
               "subnets": [
                  "vpe-zone-1"
               ]
            },
            {
               "name": "workload",
               "subnets": [
                  "vpe-zone-1"
               ]
            }
         ]
      }
   ],
   "service_endpoints": "private",
   "security_groups": [],
   "vpn_gateways": [],
   "atracker": {
      "collector_bucket_name": "atracker-bucket",
      "receive_global_events": true,
      "resource_group": "slz-service-rg",
      "add_route": false
   },
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
         "random_suffix": true,
         "resource_group": "slz-service-rg",
         "use_data": false
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
         "resource_group": "slz-service-rg",
         "use_data": false
      }
   ],
   "iam_account_settings": {
      "enable": false
   },
   "key_management": {
      "keys": [
         {
            "key_ring": "slz-slz-ring",
            "name": "slz-key",
            "root_key": true
         },
         {
            "key_ring": "slz-slz-ring",
            "name": "slz-atracker-key",
            "root_key": true
         },
         {
            "key_ring": "slz-slz-ring",
            "name": "slz-vsi-volume-key",
            "root_key": true
         }
      ],
      "name": "slz-kms",
      "resource_group": "slz-service-rg",
      "use_hs_crypto": false
   },
   "resource_groups": [
      {
         "create": true,
         "name": "slz-service-rg",
         "use_prefix": true
      },
      {
         "create": true,
         "name": "slz-management-rg",
         "use_prefix": true
      },
      {
         "create": true,
         "name": "slz-workload-rg",
         "use_prefix": true
      }
   ],
   "secrets_manager": {
      "kms_key_name": null,
      "name": null,
      "resource_group": null,
      "use_secrets_manager": false
   },
   "network_cidr": "10.0.0.0/8",
   "vpcs": [
      {
         "address_prefixes": {
            "zone-1": [],
            "zone-2": [],
            "zone-3": []
         },
         "default_security_group_rules": [],
         "flow_logs_bucket_name": null,
         "network_acls": [
            {
               "name": "management-acl",
               "rules": [
                  {
                     "action": "allow",
                     "destination": "0.0.0.0/0",
                     "direction": "inbound",
                     "name": "allow-all-inbound",
                     "source": "0.0.0.0/0"
                  },
                  {
                     "action": "allow",
                     "destination": "0.0.0.0/0",
                     "direction": "outbound",
                     "name": "allow-all-outbound",
                     "source": "0.0.0.0/0"
                  }
               ]
            }
         ],
         "prefix": "management",
         "resource_group": "slz-management-rg",
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
            "zone-2": null,
            "zone-3": null
         },
         "use_public_gateways": {
            "zone-1": false,
            "zone-2": false,
            "zone-3": false
         }
      },
      {
         "address_prefixes": {
            "zone-1": [],
            "zone-2": [],
            "zone-3": []
         },
         "default_security_group_rules": [],
         "flow_logs_bucket_name": null,
         "network_acls": [
            {
               "name": "workload-acl",
               "rules": [
                  {
                     "action": "allow",
                     "destination": "0.0.0.0/0",
                     "direction": "inbound",
                     "name": "allow-all-inbound",
                     "source": "0.0.0.0/0"
                  },
                  {
                     "action": "allow",
                     "destination": "0.0.0.0/0",
                     "direction": "outbound",
                     "name": "allow-all-outbound",
                     "source": "0.0.0.0/0"
                  }
               ]
            }
         ],
         "prefix": "workload",
         "resource_group": "slz-workload-rg",
         "subnets": {
            "zone-1": [
               {
                  "acl_name": "workload-acl",
                  "cidr": "10.20.10.0/24",
                  "name": "vsi-zone-1",
                  "public_gateway": true
               },
               {
                  "acl_name": "workload-acl",
                  "cidr": "10.20.20.0/24",
                  "name": "vpe-zone-1",
                  "public_gateway": false
               }
            ],
            "zone-2": null,
            "zone-3": null
         },
         "use_public_gateways": {
            "zone-1": false,
            "zone-2": false,
            "zone-3": false
         }
      }
   ],
   "vsi": [
      {
         "boot_volume_encryption_key_name": "slz-vsi-volume-key",
         "image_name": "ibm-ubuntu-18-04-6-minimal-amd64-2",
         "machine_type": "cx2-2x4",
         "name": "jump-box",
         "resource_group": "slz-management-rg",
         "enable_floating_ip": true,
         "security_group": {
            "name": "management",
            "rules": [
               {
                  "direction": "inbound",
                  "name": "allow-all-inbound",
                  "source": "0.0.0.0/0"
               },
               {
                  "direction": "outbound",
                  "name": "allow-all-outbound",
                  "source": "0.0.0.0/0"
               }
            ],
            "vpc_name": "management"
         },
         "ssh_keys": [
            "ssh-key"
         ],
         "subnet_names": [
            "vsi-zone-1"
         ],
         "vpc_name": "management",
         "vsi_per_subnet": 1
      },
      {
         "boot_volume_encryption_key_name": "slz-vsi-volume-key",
         "image_name": "ibm-ubuntu-18-04-6-minimal-amd64-2",
         "machine_type": "cx2-2x4",
         "name": "workload-server",
         "resource_group": "slz-workload-rg",
         "enable_floating_ip": false,
         "security_group": {
            "name": "workload",
            "rules": [
               {
                  "direction": "inbound",
                  "name": "allow-all-inbound",
                  "source": "0.0.0.0/0"
               },
               {
                  "direction": "outbound",
                  "name": "allow-all-outbound",
                  "source": "0.0.0.0/0"
               }
            ],
            "vpc_name": "workload"
         },
         "ssh_keys": [
            "ssh-key"
         ],
         "subnet_names": [
            "vsi-zone-1"
         ],
         "vpc_name": "workload",
         "vsi_per_subnet": 1
      }
   ]
}
EOF
}
