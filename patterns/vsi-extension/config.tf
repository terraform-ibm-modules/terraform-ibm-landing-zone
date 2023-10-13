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
  # VALIDATION FOR SSH_KEY
  ##############################################################################

  sshkey_var_validation = (var.ssh_public_key == null && var.existing_ssh_key_name == null) ? true : false

  # tflint-ignore: terraform_unused_declarations
  validate_ssh = local.sshkey_var_validation ? tobool("Invalid input: both ssh_public_key and existing_ssh_key_name variables cannot be null together. Please provide a value for at least one of them.") : true

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
