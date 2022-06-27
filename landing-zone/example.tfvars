##############################################################################
# Account Variables
# > These will apply to any resources created using this template
##############################################################################

ibmcloud_api_key = "<USER DEFINED INPUT>"
prefix           = "<USER DEFINED INPUT>"
region           = "us-south"
tags             = []
##############################################################################

ssh_keys = [
  {
    name       = "slz-key"
    public_key = "<USER DEFINED INPUT>"
  }
]

##############################################################################
# Resource Groups
##############################################################################
resource_groups = [{
  name = "Default"
  }, {
  name   = "slz-cs-rg"
  create = true
  }, {
  name   = "slz-management-rg"
  create = true
  }, {
  name   = "slz-workload-rg"
  create = true
}]

##############################################################################

##############################################################################
# IBM Managed Services
##############################################################################
key_management = {
  name           = "kms"
  resource_group = "Default"
  use_data       = false
  use_hs_crypto  = false
  keys = [
    {
      name     = "slz-key"
      root_key = true
      key_ring = "slz-ring"
    }
  ]
}

##############################################################################
vpcs = [
  {
    prefix         = "management"
    resource_group = "slz-management-rg"
    use_public_gateways = {
      zone-1 = false
      zone-2 = false
      zone-3 = false
    }
    network_acls = [
      {
        name = "management-acl"
        rules = [
          {
            name        = "allow-ibm-inbound"
            action      = "allow"
            direction   = "inbound"
            destination = "10.0.0.0/8"
            source      = "161.26.0.0/16"
          },
          {
            name        = "allow-all-network-inbound"
            action      = "allow"
            direction   = "inbound"
            destination = "10.0.0.0/8"
            source      = "10.0.0.0/8"
          },
          {
            name        = "allow-all-outbound"
            action      = "allow"
            direction   = "outbound"
            destination = "0.0.0.0/0"
            source      = "0.0.0.0/0"
          }
        ]
      }
    ]
    subnets = {
      zone-1 = [
        {
          name           = "vsi-zone-1"
          cidr           = "10.10.10.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        },
        {
          name           = "vpn-zone-1"
          cidr           = "10.10.20.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        },
        {
          name           = "vpe-zone-1"
          cidr           = "10.10.30.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        }
      ],
      zone-2 = [
        {
          name           = "vsi-zone-2"
          cidr           = "10.20.10.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        },
        {
          name           = "vpe-zone-2"
          cidr           = "10.20.20.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        }
      ],
      zone-3 = [
        {
          name           = "vsi-zone-3"
          cidr           = "10.30.10.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        },
        {
          name           = "vpe-zone-3"
          cidr           = "10.30.20.0/24"
          public_gateway = true
          acl_name       = "management-acl"
        }
      ]
    }
    vpn_gateways = [
      {
        name        = "vpn"
        subnet_name = "vpn-zone-1"
        connections = []
      }
    ]
  },
  {
    prefix         = "workload"
    resource_group = "slz-workload-rg"
    use_public_gateways = {
      zone-1 = false
      zone-2 = false
      zone-3 = false
    }
    network_acls = [
      {
        name = "workload-acl"
        rules = [
          {
            name        = "allow-ibm-inbound"
            action      = "allow"
            direction   = "inbound"
            destination = "10.0.0.0/8"
            source      = "161.26.0.0/16"
          },
          {
            name        = "allow-all-network-inbound"
            action      = "allow"
            direction   = "inbound"
            destination = "10.0.0.0/8"
            source      = "10.0.0.0/8"
          },
          {
            name        = "allow-all-outbound"
            action      = "allow"
            direction   = "outbound"
            destination = "0.0.0.0/0"
            source      = "0.0.0.0/0"
          }
        ]
      }
    ]
    subnets = {
      zone-1 = [
        {
          name           = "vsi-zone-1"
          cidr           = "10.40.10.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        },
        {
          name           = "vpn-zone-1"
          cidr           = "10.40.20.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        },
        {
          name           = "vpe-zone-1"
          cidr           = "10.40.30.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        }
      ],
      zone-2 = [
        {
          name           = "vsi-zone-2"
          cidr           = "10.50.10.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        },
        {
          name           = "vpe-zone-2"
          cidr           = "10.50.20.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        }
      ],
      zone-3 = [
        {
          name           = "vsi-zone-3"
          cidr           = "10.60.10.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        },
        {
          name           = "vpe-zone-3"
          cidr           = "10.60.20.0/24"
          public_gateway = true
          acl_name       = "workload-acl"
        }
      ]
    }
    vpn_gateways = []
  },
]

enable_transit_gateway      = true
transit_gateway_connections = ["management", "workload"]

##############################################################################


##############################################################################
# COS Variables
##############################################################################

cos = [{
  name           = "cos"
  use_data       = false
  resource_group = "Default"
  plan           = "standard"
  buckets = [
    {
      name          = "workload-bucket"
      storage_class = "standard"
      kms_key       = "slz-key"
      endpoint_type = "public"
      force_delete  = true
    },
    {
      name          = "atracker-bucket"
      storage_class = "standard"
      endpoint_type = "public"
      force_delete  = true
    },
    {
      name          = "management-bucket"
      storage_class = "standard"
      endpoint_type = "public"
      kms_key       = "slz-key"
      force_delete  = true
    }
  ]
  keys = [
    {
      name = "cos-bind-key"
      role = "Writer"
    }
  ]
}]

##############################################################################


##############################################################################
# Virtual Servers
##############################################################################

vsi = [
  {
    name           = "management-server"
    vpc_name       = "management"
    resource_group = "slz-management-rg"
    vsi_per_subnet = 1
    subnet_names   = ["vsi-zone-1", "vsi-zone-2", "vsi-zone-3"]
    image_name     = "ibm-ubuntu-18-04-6-minimal-amd64-2"
    machine_type   = "cx2-4x8"
    security_group = {
      name     = "management"
      vpc_name = "management"
      rules = [
        {
          name      = "allow-ibm-inbound"
          source    = "161.26.0.0/16"
          direction = "inbound"
        },
        {
          name      = "allow-vpc-inbound"
          source    = "10.0.0.0/8"
          direction = "outbound"
        },
        {
          name      = "allow-vpc-outbound"
          source    = "10.0.0.0/8"
          direction = "outbound"
        },
        {
          name      = "allow-ibm-tcp-80-outbound"
          source    = "161.26.0.0/16"
          direction = "outbound"
          tcp = {
            port_min = 80
            port_max = 80
          }
        },
        {
          name      = "allow-ibm-tcp-443-outbound"
          source    = "161.26.0.0/16"
          direction = "outbound"
          tcp = {
            port_min = 443
            port_max = 443
          }
        },
        {
          name      = "allow-ibm-udp-53-outbound"
          source    = "161.26.0.0/16"
          direction = "outbound"
          udp = {
            port_min = 53
            port_max = 53
          }
        }
      ]
    },
    ssh_keys = ["slz-key"]
  },
  {
    name           = "workload-server"
    vpc_name       = "workload"
    resource_group = "slz-workload-rg"
    vsi_per_subnet = 1
    subnet_names   = ["vsi-zone-1", "vsi-zone-2", "vsi-zone-3"]
    image_name     = "ibm-ubuntu-18-04-6-minimal-amd64-2"
    machine_type   = "cx2-4x8"
    security_group = {
      name     = "workload"
      vpc_name = "workload"
      rules = [
        {
          name      = "allow-ibm-inbound"
          source    = "161.26.0.0/16"
          direction = "inbound"
        },
        {
          name      = "allow-vpc-inbound"
          source    = "10.0.0.0/8"
          direction = "outbound"
        },
        {
          name      = "allow-vpc-outbound"
          source    = "10.0.0.0/8"
          direction = "outbound"
        },
        {
          name      = "allow-ibm-tcp-80-outbound"
          source    = "161.26.0.0/16"
          direction = "outbound"
          tcp = {
            port_min = 80
            port_max = 80
          }
        },
        {
          name      = "allow-ibm-tcp-443-outbound"
          source    = "161.26.0.0/16"
          direction = "outbound"
          tcp = {
            port_min = 443
            port_max = 443
          }
        },
        {
          name      = "allow-ibm-udp-53-outbound"
          source    = "161.26.0.0/16"
          direction = "outbound"
          udp = {
            port_min = 53
            port_max = 53
          }
        }
      ]
    }
    ssh_keys = ["slz-key"]
  }
]

security_groups = []

##############################################################################


##############################################################################
# VPE
##############################################################################

virtual_private_endpoints = [{
  service_name = "cos"
  service_type = "cloud-object-storage"
  vpcs = [{
    name    = "management"
    subnets = ["vpe-zone-1", "vpe-zone-2", "vpe-zone-3"]
    }, {
    name    = "workload"
    subnets = ["vpe-zone-1", "vpe-zone-2", "vpe-zone-3"]
  }]
}]

##############################################################################


##############################################################################
# Clusters and Worker pools
##############################################################################

clusters = [
  {
    name               = "test-cluster-2"
    vpc_name           = "workload"
    subnet_names       = ["vsi-zone-1", "vsi-zone-2", "vsi-zone-3"]
    workers_per_subnet = 2
    machine_type       = "bx2.16x64"
    kube_type          = "openshift"
    resource_group     = "Default"
    cos_name           = "cos"
    worker_pools = [
      {
        name               = "worker-pool-1"
        vpc_name           = "workload"
        subnet_names       = ["vsi-zone-1"]
        workers_per_subnet = 1
        flavor             = "bx2.16x64"
      },
      {
        name               = "worker-pool-2"
        vpc_name           = "workload"
        subnet_names       = ["vsi-zone-2"]
        workers_per_subnet = 1
        flavor             = "bx2.16x64"
    }]
  },
  {
    name               = "test-cluster-1"
    vpc_name           = "workload"
    subnet_names       = ["vsi-zone-1", "vsi-zone-2", "vsi-zone-3"]
    workers_per_subnet = 1
    machine_type       = "bx2.16x64"
    kube_type          = "iks"
    resource_group     = "Default"
    worker_pools = [
      {
        name               = "worker-pool-1"
        vpc_name           = "workload"
        subnet_names       = ["vsi-zone-1"]
        workers_per_subnet = 1
        flavor             = "bx2.16x64"
    }]
  }
]

##############################################################################
