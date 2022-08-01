##############################################################################
# Dynamic Values
##############################################################################

module "dynamic_values" {
  source               = "./dynamic_values"
  prefix               = "${var.prefix}-${var.name}"
  region               = var.region
  address_prefixes     = var.address_prefixes
  routes               = var.routes
  use_public_gateways  = var.use_public_gateways
  security_group_rules = var.security_group_rules
  network_cidr         = var.network_cidr
  network_acls         = var.network_acls
  subnets              = var.subnets
  public_gateways      = ibm_is_public_gateway.gateway
}

##############################################################################


##############################################################################
# Unit Tests
##############################################################################

module "unit_tests" {
  source = "./dynamic_values"
  prefix = "ut"
  region = "us-south"
  address_prefixes = {
    zone-1 = ["1"]
    zone-2 = ["2"]
    zone-3 = null
  }
  routes = [
    {
      name        = "test-route"
      zone        = 1
      destination = "test"
      next_hop    = "test"
    }
  ]
  use_public_gateways = {
    zone-1 = true
    zone-2 = null
    zone-3 = true
  }
  security_group_rules = [
    {
      name  = "test-rule"
      field = "field"
    }
  ]
  network_cidr = "1.2.3.4/5"
  network_acls = [
    {
      name              = "acl"
      add_cluster_rules = true
      rules = [
        {
          name = "test-rule"
        }
      ]
    }
  ]
  subnets = {
    zone-1 = [
      {
        name           = "subnet-1"
        cidr           = "2.3.4.5/6"
        public_gateway = true
        acl_name       = "acl"
      },
      {
        name           = "subnet-2"
        cidr           = "2.3.4.5/7"
        acl_name       = "acl"
        public_gateway = null
      }
    ]
    zone-2 = [
      {
        name           = "subnet-3"
        cidr           = "2.3.4.5/8"
        acl_name       = "acl"
        public_gateway = true
      }
    ]
    zone-3 = null
  }
  public_gateways = {
    zone-1 = {
      id = "pgw1"
    }
    zone-3 = {
      id = "pgw2"
    }
  }
}

##############################################################################
