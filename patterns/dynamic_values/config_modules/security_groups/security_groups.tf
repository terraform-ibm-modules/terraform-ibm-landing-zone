##############################################################################
# Variables
##############################################################################

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a letter and end with a letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters."
  type        = string

  validation {
    error_message = "Prefix must begin and end with a letter and contain only letters, numbers, and - characters. Prefixes must end with a letter or number and be 16 or fewer characters."
    condition     = can(regex("^([A-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.prefix)) && length(var.prefix) <= 16
  }
}

variable "f5_vpc_name" {
  description = "Name of the VPC where F5 will be provisioned"
  type        = string
}

variable "bastion_vpc_name" {
  description = "Name of the VPC where bastion will be provisioned"
  type        = string
}

variable "f5_resource_group" {
  description = "Name of F5 resource group"
  type        = string
}

variable "bastion_vsi_rules" {
  description = "List of rules for F5 External security group."
  type = list(
    object({
      name      = string
      source    = string
      direction = string
      tcp = object({
        port_min = string
        port_max = string
      })
    })
  )
}

variable "f5_management_rules" {
  description = "List of rules for F5 Management security group."
  type = list(
    object({
      name      = string
      source    = string
      direction = string
      tcp = object({
        port_min = string
        port_max = string
      })
    })
  )
}

variable "f5_external_rules" {
  description = "List of rules for F5 External security group."
  type = list(
    object({
      name      = string
      source    = string
      direction = string
      tcp = object({
        port_min = string
        port_max = string
      })
    })
  )
}

variable "f5_bastion_rules" {
  description = "List of rules for F5 External security group."
  type = list(
    object({
      name      = string
      source    = string
      direction = string
      tcp = object({
        port_min = string
        port_max = string
      })
    })
  )
}

variable "f5_workload_rules" {
  description = "List of rules for F5 Workload security group."
  type = list(
    object({
      name      = string
      source    = string
      direction = string
      tcp = object({
        port_min = string
        port_max = string
      })
    })
  )
}

##############################################################################

##############################################################################
# Outputs
##############################################################################

output "f5_management" {
  description = "F5 Management Interface Security Group"
  value = {
    name           = "f5-management-sg"
    vpc_name       = var.f5_vpc_name
    resource_group = var.f5_resource_group
    rules          = var.f5_management_rules
  }
}

output "f5_external" {
  description = "F5 External Interface Security Group"
  value = {
    name           = "f5-external-sg"
    vpc_name       = var.f5_vpc_name
    resource_group = var.f5_resource_group
    rules          = var.f5_external_rules
  }
}

output "f5_workload" {
  description = "F5 Workload Interface Security Group"
  value = {
    name           = "f5-workload-sg"
    vpc_name       = var.f5_vpc_name
    resource_group = var.f5_resource_group
    rules          = var.f5_workload_rules
  }
}

output "f5_bastion" {
  description = "F5 Bastion Interface Security Group"
  value = {
    name           = "f5-bastion-sg"
    vpc_name       = var.f5_vpc_name
    resource_group = var.f5_resource_group
    rules          = var.f5_bastion_rules
  }
}

output "bastion_vsi" {
  description = "Security Group for Bastion VSI"
  value = {
    name           = "bastion-vsi-sg"
    vpc_name       = var.bastion_vpc_name
    resource_group = "${var.prefix}-${var.bastion_vpc_name}-rg"
    rules          = var.bastion_vsi_rules
    access_tags    = []
  }
}

##############################################################################
