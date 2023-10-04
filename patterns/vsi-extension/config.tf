##############################################################################
# Create Pattern Dynamic Variables
# > Values are created inside the `dynamic_modules/` module to allow them to
#   be tested
##############################################################################

module "dynamic_values" {
  source = "../dynamic_values"
  prefix = var.prefix
  region = var.region
  vpcs   = [data.ibm_is_vpc.vpc_by_id.name]
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
    # VSI Configuration
    ##############################################################################
    # vsi = [
    #   # Create an identical VSI deployment in each VPC
    #   for network in var.vpcs :
    #   {
    #     name                            = "${network}-server"
    #     vpc_name                        = network
    #     resource_group                  = "${var.prefix}-${network}-rg"
    #     subnet_names                    = ["vsi-zone-1", "vsi-zone-2", "vsi-zone-3"]
    #     image_name                      = var.vsi_image_name
    #     vsi_per_subnet                  = var.vsi_per_subnet
    #     machine_type                    = var.vsi_instance_profile
    #     boot_volume_encryption_key_name = "${var.prefix}-vsi-volume-key"
    #     security_group = {
    #       name     = "${var.prefix}-${network}"
    #       vpc_name = var.vpcs[0]
    #       rules    = module.dynamic_values.default_vsi_sg_rules
    #     },
    #     ssh_keys = [local.ssh_keys[0].name]
    #   }
    # ]
    ##############################################################################
    ##############################################################################
    # Deployment Configuration From Dynamic Values
    ##############################################################################

    security_groups = module.dynamic_values.security_groups

    ##############################################################################
  }

  ##############################################################################
  # Compile Environment for Config output
  ##############################################################################
  env = {
    security_groups = local.config.security_groups
  }
  ##############################################################################

  string = "\"${jsonencode(local.env)}\""
}

##############################################################################
