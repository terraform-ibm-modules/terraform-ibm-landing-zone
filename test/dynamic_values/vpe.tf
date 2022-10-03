##############################################################################
# Virtual Private Endpoints
##############################################################################

module "vpe" {
  source                    = "./config_modules/vpe"
  prefix                    = var.prefix
  region                    = var.region
  virtual_private_endpoints = var.virtual_private_endpoints
  vpc_modules               = var.vpc_modules
  cos_instance_ids          = local.cos_instance_ids
}

##############################################################################

##############################################################################
# [Unit Test] VPE
##############################################################################

module "ut_vpe" {
  source = "./config_modules/vpe"
  prefix = "ut"
  region = "us-south"
  virtual_private_endpoints = [{
    service_name   = "test-cos",
    service_type   = "cloud-object-storage"
    resource_group = "test-rg"
    vpcs = [
      {
        name = "test"
        subnets = [
          "vpe-zone-1"
        ]
      }
    ]
  }]
  vpc_modules = {
    test = {
      vpc_id = "1234"
      subnet_zone_list = [
        {
          name = "ut-test-vpe-zone-1"
          id   = "vpe-id"
          zone = "vpe-zone"
          cidr = "vpe"
      }]
    }
  }
  cos_instance_ids = {
    test-cos = {
      name = "ut-test-cos"
      id   = ":::::::1234"
    }
  }
}

locals {
  assert_vpe_exists_in_map                                   = lookup(module.ut_vpe.vpe_services, "test-cos-cloud-object-storage")
  assert_vpe_has_correct_crn                                 = regex("crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.us-south.cloud-object-storage.appdomain.cloud", module.ut_vpe.vpe_services["test-cos-cloud-object-storage"].crn)
  assert_vpe_has_correct_id                                  = regex("crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.us-south.cloud-object-storage.appdomain.cloud", module.ut_vpe.vpe_services["test-cos-cloud-object-storage"].crn)
  assert_vpe_gateway_map_contains_gateway                    = lookup(module.ut_vpe.vpe_gateway_map, "test-test-cos")
  assert_vpe_gateway_correct_vpc_id                          = regex("1234", module.ut_vpe.vpe_gateway_map["test-test-cos"].vpc_id)
  assert_vpe_gateway_correct_service_crn                     = regex("crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.us-south.cloud-object-storage.appdomain.cloud", module.ut_vpe.vpe_gateway_map["test-test-cos"].crn)
  assert_vpe_subnet_reserved_ip_map_contains_ip              = lookup(module.ut_vpe.vpe_subnet_reserved_ip_map, "test-test-cos-gateway-vpe-zone-1-ip")
  assert_vpe_subnet_reserved_ip_map_has_correct_gateway_name = regex("test-test-cos", module.ut_vpe.vpe_subnet_reserved_ip_map["test-test-cos-gateway-vpe-zone-1-ip"].gateway_name)
  assert_vpe_subnet_reserved_ip_map_has_correct_subnet_id    = regex("vpe-id", module.ut_vpe.vpe_subnet_reserved_ip_map["test-test-cos-gateway-vpe-zone-1-ip"].id)
}


##############################################################################
