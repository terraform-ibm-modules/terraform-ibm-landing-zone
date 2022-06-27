##############################################################################
# VPC GUID
##############################################################################

output "vpc_name" {
  description = "Name of VPC created"
  value       = ibm_is_vpc.vpc.name
}

output "vpc_id" {
  description = "ID of VPC created"
  value       = ibm_is_vpc.vpc.id
}

output "vpc_crn" {
  description = "CRN of VPC created"
  value       = ibm_is_vpc.vpc.crn
}

##############################################################################


##############################################################################
# Subnet Outputs
##############################################################################

output "subnet_ids" {
  description = "The IDs of the subnets"
  value = [
    for subnet in ibm_is_subnet.subnet :
    subnet.id
  ]
}

output "subnet_detail_list" {
  description = "A list of subnets containing names, CIDR blocks, and zones."
  value = {
    for zone_name in distinct([
      for subnet in ibm_is_subnet.subnet :
      subnet.zone
    ]) :
    zone_name => {
      for subnet in ibm_is_subnet.subnet :
      subnet.name => {
        id   = subnet.id
        cidr = subnet.ipv4_cidr_block
      } if subnet.zone == zone_name
    }
  }
}

output "subnet_zone_list" {
  description = "A list containing subnet IDs and subnet zones"
  value = [
    for subnet in ibm_is_subnet.subnet : {
      name = subnet.name
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.ipv4_cidr_block
    }
  ]
}

##############################################################################
