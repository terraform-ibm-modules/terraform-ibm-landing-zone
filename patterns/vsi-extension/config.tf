##############################################################################
# Create Pattern Dynamic Variables
# > Values are created inside the `dynamic_modules/` module to allow them to
#   be tested
##############################################################################

module "default_vsi_sg_rules" {
  source = "../dynamic_values/config_modules/default_security_group_rules"
}
##############################################################################


##############################################################################
# Dynamically Create Default Configuration
##############################################################################

locals {
  ##############################################################################
  # Default SSH key
  ##############################################################################

  ssh_keys = {
    name       = var.ssh_public_key != null ? "${var.prefix}-ssh-key" : var.existing_ssh_key_name
    public_key = var.existing_ssh_key_name == null ? var.ssh_public_key : null
  }

  ##############################################################################

  ##############################################################################
  # Dynamic configuration for landing zone environment
  ##############################################################################

  config = {
    ##############################################################################
    # Deployment Configuration From Dynamic Values
    ##############################################################################

    security_groups = flatten(
      [
        {
          name           = "${data.ibm_is_vpc.vpc_by_id.name}-vpe-sg"
          resource_group = data.ibm_is_vpc.vpc_by_id.resource_group_name
          rules          = module.default_vsi_sg_rules.all_tcp_rules
          vpc_name       = data.ibm_is_vpc.vpc_by_id.name
        }
      ]
    )

    ##############################################################################
  }

  ##############################################################################
  # Compile Environment for Config output
  ##############################################################################
  env = {
    security_groups = local.config.security_groups
  }
  ##############################################################################
}

##############################################################################
